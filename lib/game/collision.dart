// Simple, stable XZ collision: a circle (player) against axis-aligned boxes
// and the world boundary. Movement is resolved per axis so the player slides
// along walls instead of sticking.
import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' as vm;

class BoxCollider {
  const BoxCollider(this.minX, this.minZ, this.maxX, this.maxZ, {this.id});

  factory BoxCollider.centered(
    double x,
    double z,
    double width,
    double depth, {
    String? id,
  }) => BoxCollider(
    x - width / 2,
    z - depth / 2,
    x + width / 2,
    z + depth / 2,
    id: id,
  );

  final double minX, minZ, maxX, maxZ;
  final String? id;

  bool overlapsCircle(double cx, double cz, double radius) {
    final nx = cx.clamp(minX, maxX);
    final nz = cz.clamp(minZ, maxZ);
    final dx = cx - nx, dz = cz - nz;
    return dx * dx + dz * dz < radius * radius;
  }

  /// Distance from a point to the nearest point on the box (0 if inside).
  double distanceTo(double cx, double cz) {
    final nx = cx.clamp(minX, maxX);
    final nz = cz.clamp(minZ, maxZ);
    return math.sqrt(math.pow(cx - nx, 2) + math.pow(cz - nz, 2));
  }
}

class WorldBounds {
  const WorldBounds(this.minX, this.minZ, this.maxX, this.maxZ);
  final double minX, minZ, maxX, maxZ;
}

class CollisionWorld {
  CollisionWorld({
    required this.bounds,
    Iterable<BoxCollider> colliders = const [],
  }) : colliders = List.of(colliders);

  final WorldBounds bounds;
  final List<BoxCollider> colliders;

  bool blocked(double x, double z, double radius) {
    if (x - radius < bounds.minX ||
        x + radius > bounds.maxX ||
        z - radius < bounds.minZ ||
        z + radius > bounds.maxZ) {
      return true;
    }
    for (final c in colliders) {
      if (c.overlapsCircle(x, z, radius)) return true;
    }
    return false;
  }

  /// Moves [position] by [delta], then pushes the player circle out of any
  /// overlapping box along the shortest separation so it slides along walls
  /// and around corners instead of sticking. Returns the new position (y
  /// preserved).
  vm.Vector3 move(vm.Vector3 position, vm.Vector2 delta, double radius) {
    var x = position.x + delta.x, z = position.z + delta.y;
    for (var iteration = 0; iteration < 4; iteration++) {
      var resolved = false;
      for (final c in colliders) {
        final nx = x.clamp(c.minX, c.maxX), nz = z.clamp(c.minZ, c.maxZ);
        final dx = x - nx, dz = z - nz;
        final d2 = dx * dx + dz * dz;
        if (d2 >= radius * radius) continue;
        resolved = true;
        if (d2 < 1e-9) {
          // Center inside the box: exit through the nearest face.
          final left = x - c.minX, right = c.maxX - x;
          final front = z - c.minZ, back = c.maxZ - z;
          final m = math.min(math.min(left, right), math.min(front, back));
          if (m == left) {
            x = c.minX - radius;
          } else if (m == right) {
            x = c.maxX + radius;
          } else if (m == front) {
            z = c.minZ - radius;
          } else {
            z = c.maxZ + radius;
          }
        } else {
          final d = math.sqrt(d2);
          final push = radius - d + 1e-4;
          x += dx / d * push;
          z += dz / d * push;
        }
      }
      if (!resolved) break;
    }
    x = x.clamp(bounds.minX + radius, bounds.maxX - radius);
    z = z.clamp(bounds.minZ + radius, bounds.maxZ - radius);
    return vm.Vector3(x, position.y, z);
  }
}
