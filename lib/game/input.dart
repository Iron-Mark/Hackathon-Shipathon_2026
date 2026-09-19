// Normalized gameplay input. Keyboard and touch adapters both write here;
// the player controller only ever reads this.
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math.dart' as vm;

class InputState {
  /// Movement in screen terms: x right, y forward (up on screen). Length <= 1.
  vm.Vector2 movement = vm.Vector2.zero();

  bool _interactPressed = false;

  /// Queues one interact press; consumed by the runtime on the next tick.
  void pressInteract() => _interactPressed = true;

  bool consumeInteract() {
    final pressed = _interactPressed;
    _interactPressed = false;
    return pressed;
  }

  void clear() {
    movement = vm.Vector2.zero();
    _interactPressed = false;
  }
}

/// WASD / arrow keys -> movement, E / Space / Enter -> interact.
class KeyboardInputAdapter {
  KeyboardInputAdapter(this.state);
  final InputState state;
  final Set<LogicalKeyboardKey> _down = {};
  vm.Vector2 _keyboardMovement = vm.Vector2.zero();

  static final interactKeys = {
    LogicalKeyboardKey.keyE,
    LogicalKeyboardKey.space,
    LogicalKeyboardKey.enter,
  };

  /// Returns true when the key is part of the gameplay control scheme.
  bool handle(KeyEvent event) {
    final key = event.logicalKey;
    if (interactKeys.contains(key)) {
      if (event is KeyDownEvent) state.pressInteract();
      return true;
    }
    if (!_isMovementKey(key)) return false;
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _down.add(key);
    } else if (event is KeyUpEvent) {
      _down.remove(key);
    }
    _recompute();
    return true;
  }

  bool _isMovementKey(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.keyW ||
      key == LogicalKeyboardKey.keyA ||
      key == LogicalKeyboardKey.keyS ||
      key == LogicalKeyboardKey.keyD ||
      key == LogicalKeyboardKey.arrowUp ||
      key == LogicalKeyboardKey.arrowDown ||
      key == LogicalKeyboardKey.arrowLeft ||
      key == LogicalKeyboardKey.arrowRight;

  void _recompute() {
    var x = 0.0, y = 0.0;
    if (_down.contains(LogicalKeyboardKey.keyW) ||
        _down.contains(LogicalKeyboardKey.arrowUp)) {
      y += 1;
    }
    if (_down.contains(LogicalKeyboardKey.keyS) ||
        _down.contains(LogicalKeyboardKey.arrowDown)) {
      y -= 1;
    }
    if (_down.contains(LogicalKeyboardKey.keyD) ||
        _down.contains(LogicalKeyboardKey.arrowRight)) {
      x += 1;
    }
    if (_down.contains(LogicalKeyboardKey.keyA) ||
        _down.contains(LogicalKeyboardKey.arrowLeft)) {
      x -= 1;
    }
    _keyboardMovement = vm.Vector2(x, y);
    if (_keyboardMovement.length > 1) _keyboardMovement.normalize();
    state.movement = _keyboardMovement;
  }

  /// Drops held keys (focus lost, panel opened) so the player stops moving.
  void release() {
    _down.clear();
    _keyboardMovement = vm.Vector2.zero();
    state.movement = vm.Vector2.zero();
  }
}

/// Virtual joystick -> movement. Screen-space input has -y for "up".
class TouchInputAdapter {
  TouchInputAdapter(this.state);
  final InputState state;

  void onJoystick(vm.Vector2 screenDirection) {
    final m = vm.Vector2(screenDirection.x, -screenDirection.y);
    if (m.length > 1) m.normalize();
    state.movement = m;
  }
}
