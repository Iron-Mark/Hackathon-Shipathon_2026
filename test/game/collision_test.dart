import 'package:flutter_test/flutter_test.dart';
import 'package:iron_ascent/game/collision.dart';
import 'package:iron_ascent/game/interaction.dart';
import 'package:vector_math/vector_math.dart' as vm;

import '../support/test_content.dart';

void main() {
  final world = CollisionWorld(
    bounds: const WorldBounds(0.5, 0.5, 15.5, 11.5),
    colliders: [BoxCollider.centered(3.0, 5.5, 0.8, 0.65, id: 'coach')],
  );
  const r = 0.32;

  vm.Vector3 at(double x, double z) => vm.Vector3(x, 0, z);

  test('player cannot walk through a machine or NPC', () {
    var p = at(3.0, 7.0);
    for (var i = 0; i < 40; i++) {
      p = world.move(p, vm.Vector2(0, -0.1), r);
    }
    expect(p.z, greaterThanOrEqualTo(5.825 + r - 1e-3));
    expect(world.blocked(p.x, p.z, r), isFalse);
  });

  test('player slides along a wall instead of sticking', () {
    var p = at(3.0, 5.825 + r + 0.01);
    final before = p.x;
    p = world.move(p, vm.Vector2(0.5, -0.2), r);
    expect(p.x, greaterThan(before + 0.4));
    expect(world.blocked(p.x, p.z, r), isFalse);
  });

  test('player slides around a corner', () {
    var p = at(2.6 - r - 0.01, 6.15);
    for (var i = 0; i < 10; i++) {
      p = world.move(p, vm.Vector2(0.1, 0), r);
    }
    expect(p.x, greaterThan(2.6));
    expect(world.blocked(p.x, p.z, r), isFalse);
  });

  test('player is constrained to the world boundary', () {
    var p = at(1.0, 1.0);
    for (var i = 0; i < 30; i++) {
      p = world.move(p, vm.Vector2(-0.2, -0.2), r);
    }
    expect(p.x, closeTo(0.5 + r, 1e-6));
    expect(p.z, closeTo(0.5 + r, 1e-6));
  });

  test('interaction system picks the nearest in-range target only', () {
    final content = loadTestContent();
    final system = InteractionSystem(content.district.interactables);
    expect(system.select(vm.Vector2(2.5, 8.0), vm.Vector2(0, -1)), isNull);
    final nearCoach = system.select(vm.Vector2(3.0, 6.6), vm.Vector2(0, -1));
    expect(nearCoach?.id, 'hypertrophy_coach');
    final nearIncline = system.select(vm.Vector2(6.0, 5.0), vm.Vector2(0, -1));
    expect(nearIncline?.id, 'incline_station_01');
  });
}
