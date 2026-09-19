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

  /// Moves [position] by [delta], sliding along obstacles. Returns the new
  /// position (y preserved).
  vm.Vector3 move(vm.Vector3 position, vm.Vector2 delta, double radius) {
    var x = position.x, z = position.z;
    final nx = x + delta.x;
    if (!blocked(nx, z, radius)) {
      x = nx;
    }
    final nz = z + delta.y;
    if (!blocked(x, nz, radius)) {
      z = nz;
    }
    // If we somehow started inside geometry, keep the player inside bounds.
    x = x.clamp(bounds.minX + radius, bounds.maxX - radius);
    z = z.clamp(bounds.minZ + radius, bounds.maxZ - radius);
    return vm.Vector3(x, position.y, z);
  }
}
