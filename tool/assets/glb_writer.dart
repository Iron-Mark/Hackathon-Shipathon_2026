// Minimal glTF 2.0 binary (GLB) writer for low-poly kit-bashed models.
//
// Models are assembled from flat-shaded boxes and cylinders grouped into
// named nodes (so the runtime can animate limbs by name). Materials are
// deduplicated PBR metallic-roughness factors: no textures, small files.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart';

class Mat {
  const Mat(
    this.name,
    this.r,
    this.g,
    this.b, {
    this.metallic = 0.0,
    this.roughness = 0.9,
    this.emissive = 0.0,
  });
  final String name;
  final double r, g, b, metallic, roughness, emissive;

  Map<String, dynamic> toJson() => {
    'name': name,
    'pbrMetallicRoughness': {
      'baseColorFactor': [r, g, b, 1.0],
      'metallicFactor': metallic,
      'roughnessFactor': roughness,
    },
    if (emissive > 0) 'emissiveFactor': [r * emissive, g * emissive, b * emissive],
  };
}

class _Prim {
  _Prim(this.material);
  final Mat material;
  final positions = <double>[];
  final normals = <double>[];
  final indices = <int>[];
  int get vertexCount => positions.length ~/ 3;

  void quad(Vector3 a, Vector3 b, Vector3 c, Vector3 d) {
    // a,b,c,d counter-clockwise seen from outside.
    final n = (b - a).cross(c - a)..normalize();
    final base = vertexCount;
    for (final v in [a, b, c, d]) {
      positions.addAll([v.x, v.y, v.z]);
      normals.addAll([n.x, n.y, n.z]);
    }
    indices.addAll([base, base + 1, base + 2, base, base + 2, base + 3]);
  }

  void tri(Vector3 a, Vector3 b, Vector3 c) {
    final n = (b - a).cross(c - a)..normalize();
    final base = vertexCount;
    for (final v in [a, b, c]) {
      positions.addAll([v.x, v.y, v.z]);
      normals.addAll([n.x, n.y, n.z]);
    }
    indices.addAll([base, base + 1, base + 2]);
  }
}

class NodeBuilder {
  NodeBuilder(this.name, this.origin);
  final String name;
  final Vector3 origin;
  final Map<Mat, _Prim> _prims = {};
  final children = <NodeBuilder>[];

  _Prim _prim(Mat m) => _prims.putIfAbsent(m, () => _Prim(m));

  NodeBuilder child(String name, Vector3 origin) {
    final n = NodeBuilder(name, origin);
    children.add(n);
    return n;
  }

  /// Axis-aligned box (before [rotation]) centered at [center] in node space.
  void box(Vector3 center, Vector3 size, Mat m, {Matrix3? rotation}) {
    final h = size / 2.0;
    Vector3 p(double x, double y, double z) {
      var v = Vector3(x * h.x, y * h.y, z * h.z);
      if (rotation != null) v = rotation.transform(v);
      return v + center;
    }

    final prim = _prim(m);
    // +Z front
    prim.quad(p(-1, -1, 1), p(1, -1, 1), p(1, 1, 1), p(-1, 1, 1));
    // -Z back
    prim.quad(p(1, -1, -1), p(-1, -1, -1), p(-1, 1, -1), p(1, 1, -1));
    // +X
    prim.quad(p(1, -1, 1), p(1, -1, -1), p(1, 1, -1), p(1, 1, 1));
    // -X
    prim.quad(p(-1, -1, -1), p(-1, -1, 1), p(-1, 1, 1), p(-1, 1, -1));
    // +Y top
    prim.quad(p(-1, 1, 1), p(1, 1, 1), p(1, 1, -1), p(-1, 1, -1));
    // -Y bottom
    prim.quad(p(-1, -1, -1), p(1, -1, -1), p(1, -1, 1), p(-1, -1, 1));
  }

  /// Cylinder along [axis] (unit vector) centered at [center].
  void cylinder(
    Vector3 center,
    double radius,
    double length,
    Mat m, {
    int segments = 10,
    Vector3? axis,
    double topRadius = -1,
  }) {
    final a = (axis ?? Vector3(0, 1, 0)).normalized();
    final rTop = topRadius < 0 ? radius : topRadius;
    // Build an orthonormal basis (u, v) perpendicular to a.
    final helper = a.y.abs() < 0.9 ? Vector3(0, 1, 0) : Vector3(1, 0, 0);
    final u = a.cross(helper)..normalize();
    final v = a.cross(u)..normalize();
    final half = a * (length / 2);
    final top = center + half;
    final bottom = center - half;
    final prim = _prim(m);
    Vector3 ring(Vector3 c, double r, int i) {
      final t = 2 * math.pi * i / segments;
      return c + u * (math.cos(t) * r) + v * (math.sin(t) * r);
    }

    for (var i = 0; i < segments; i++) {
      final b0 = ring(bottom, radius, i), b1 = ring(bottom, radius, i + 1);
      final t0 = ring(top, rTop, i), t1 = ring(top, rTop, i + 1);
      prim.quad(b1, b0, t0, t1);
      if (rTop > 0) prim.tri(top, t0, t1);
      prim.tri(bottom, b1, b0);
    }
  }
}

class GlbModel {
  GlbModel(this.name);
  final String name;
  final roots = <NodeBuilder>[];

  NodeBuilder node(String name, [Vector3? origin]) {
    final n = NodeBuilder(name, origin ?? Vector3.zero());
    roots.add(n);
    return n;
  }

  Uint8List build() {
    final bin = BytesBuilder();
    final bufferViews = <Map<String, dynamic>>[];
    final accessors = <Map<String, dynamic>>[];
    final materials = <Mat, int>{};
    final materialJson = <Map<String, dynamic>>[];
    final meshes = <Map<String, dynamic>>[];
    final nodes = <Map<String, dynamic>>[];
    var triangles = 0;

    int addView(Uint8List data, int target) {
      while (bin.length % 4 != 0) {
        bin.addByte(0);
      }
      bufferViews.add({
        'buffer': 0,
        'byteOffset': bin.length,
        'byteLength': data.length,
        'target': target,
      });
      bin.add(data);
      return bufferViews.length - 1;
    }

    int matIndex(Mat m) => materials.putIfAbsent(m, () {
      materialJson.add(m.toJson());
      return materialJson.length - 1;
    });

    int addMesh(NodeBuilder n) {
      final prims = <Map<String, dynamic>>[];
      for (final prim in n._prims.values) {
        if (prim.indices.isEmpty) continue;
        triangles += prim.indices.length ~/ 3;
        final pos = Float32List.fromList(prim.positions);
        final nor = Float32List.fromList(prim.normals);
        final min = [double.infinity, double.infinity, double.infinity];
        final max = [-double.infinity, -double.infinity, -double.infinity];
        for (var i = 0; i < pos.length; i += 3) {
          for (var k = 0; k < 3; k++) {
            min[k] = math.min(min[k], pos[i + k]);
            max[k] = math.max(max[k], pos[i + k]);
          }
        }
        final posView = addView(pos.buffer.asUint8List(), 34962);
        accessors.add({
          'bufferView': posView,
          'componentType': 5126,
          'count': prim.vertexCount,
          'type': 'VEC3',
          'min': min,
          'max': max,
        });
        final posAcc = accessors.length - 1;
        final norView = addView(nor.buffer.asUint8List(), 34962);
        accessors.add({
          'bufferView': norView,
          'componentType': 5126,
          'count': prim.vertexCount,
          'type': 'VEC3',
        });
        final norAcc = accessors.length - 1;
        final wide = prim.vertexCount > 65535;
        final idxBytes = wide
            ? Uint32List.fromList(prim.indices).buffer.asUint8List()
            : Uint16List.fromList(prim.indices).buffer.asUint8List();
        final idxView = addView(idxBytes, 34963);
        accessors.add({
          'bufferView': idxView,
          'componentType': wide ? 5125 : 5123,
          'count': prim.indices.length,
          'type': 'SCALAR',
        });
        prims.add({
          'attributes': {'POSITION': posAcc, 'NORMAL': norAcc},
          'indices': accessors.length - 1,
          'material': matIndex(prim.material),
          'mode': 4,
        });
      }
      meshes.add({'name': '${n.name}_mesh', 'primitives': prims});
      return meshes.length - 1;
    }

    int addNode(NodeBuilder n) {
      final index = nodes.length;
      nodes.add({'name': n.name});
      final json = nodes[index];
      if (n.origin.length2 > 0) {
        json['translation'] = [n.origin.x, n.origin.y, n.origin.z];
      }
      if (n._prims.values.any((p) => p.indices.isNotEmpty)) {
        json['mesh'] = addMesh(n);
      }
      if (n.children.isNotEmpty) {
        json['children'] = n.children.map(addNode).toList();
      }
      return index;
    }

    final rootIndices = roots.map(addNode).toList();
    while (bin.length % 4 != 0) {
      bin.addByte(0);
    }
    final binBytes = bin.toBytes();

    final gltf = {
      'asset': {
        'version': '2.0',
        'generator': 'IRON ASCENT tool/assets/generate_models.dart',
        'copyright': 'Original low-poly asset generated for IRON ASCENT.',
      },
      'scene': 0,
      'scenes': [
        {'name': name, 'nodes': rootIndices},
      ],
      'nodes': nodes,
      'meshes': meshes,
      'materials': materialJson,
      'accessors': accessors,
      'bufferViews': bufferViews,
      'buffers': [
        {'byteLength': binBytes.length},
      ],
      'extras': {'triangles': triangles},
    };
    final jsonList = List<int>.of(utf8.encode(jsonEncode(gltf)));
    while (jsonList.length % 4 != 0) {
      jsonList.add(0x20);
    }
    final jsonBytes = Uint8List.fromList(jsonList);

    final out = BytesBuilder();
    void u32(int v) {
      final b = ByteData(4)..setUint32(0, v, Endian.little);
      out.add(b.buffer.asUint8List());
    }

    u32(0x46546C67); // glTF
    u32(2);
    u32(12 + 8 + jsonBytes.length + 8 + binBytes.length);
    u32(jsonBytes.length);
    u32(0x4E4F534A); // JSON
    out.add(jsonBytes);
    u32(binBytes.length);
    u32(0x004E4942); // BIN
    out.add(binBytes);
    return out.toBytes();
  }

  int write(String path) {
    final bytes = build();
    File(path)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(bytes);
    return bytes.length;
  }
}

Matrix3 rotX(double degrees) => Matrix3.rotationX(degrees * math.pi / 180);
Matrix3 rotY(double degrees) => Matrix3.rotationY(degrees * math.pi / 180);
Matrix3 rotZ(double degrees) => Matrix3.rotationZ(degrees * math.pi / 180);
Vector3 v3(double x, double y, double z) => Vector3(x, y, z);
