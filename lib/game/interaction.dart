// Interaction detection: one contextual target chosen by proximity, with a
// preference for objects roughly in front of the player.
import 'dart:math' as math;

import 'package:vector_math/vector_math.dart' as vm;

import '../domain/content.dart';
import 'collision.dart';

class Interactable {
  Interactable(this.definition)
    : collider = BoxCollider.centered(
        definition.x,
        definition.z,
        definition.width,
        definition.depth,
        id: definition.id,
      );

  final InteractableDefinition definition;
  final BoxCollider collider;

  String get id => definition.id;
  vm.Vector2 get center => vm.Vector2(definition.x, definition.z);

  bool inRange(vm.Vector2 player) =>
      collider.distanceTo(player.x, player.y) <=
      definition.interactionRadius - 0.3;
}

class InteractionSystem {
  InteractionSystem(Iterable<InteractableDefinition> definitions)
    : interactables = definitions.map(Interactable.new).toList();

  final List<Interactable> interactables;

  Interactable? byId(String id) =>
      interactables.where((i) => i.id == id).firstOrNull;

  /// Nearest in-range interactable. When two are similarly close, prefer the
  /// one in front of the player ([facing] is a unit XZ direction).
  Interactable? select(vm.Vector2 player, vm.Vector2 facing) {
    Interactable? best;
    var bestScore = double.infinity;
    for (final i in interactables) {
      if (!i.inRange(player)) continue;
      final toTarget = i.center - player;
      final distance = toTarget.length;
      var score = distance;
      if (distance > 1e-3 && facing.length2 > 1e-6) {
        final alignment = toTarget.normalized().dot(facing); // -1..1
        score -= alignment * 0.6; // small "in front" preference
      }
      if (score < bestScore) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }

  /// Squared distance helper for HUD ordering/debugging.
  static double distance2(Interactable i, vm.Vector2 p) =>
      math.pow(i.center.x - p.x, 2) + math.pow(i.center.y - p.y, 2) as double;
}
