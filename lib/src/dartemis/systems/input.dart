import 'dart:async';

import 'package:dartemis/dartemis.dart';
import 'package:web/web.dart';

abstract class GenericInputHandlingSystem extends EntityProcessingSystem {
  /// to prevent scrolling
  final Set<int> preventDefaultKeys = <int>{
    KeyCode.UP,
    KeyCode.DOWN,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.SPACE,
  };
  final Map<int, bool> keyState = <int, bool>{};
  final Map<int, bool> unpress = <int, bool>{};
  late final StreamSubscription<KeyboardEvent> _onKeyUpSubscription;
  late final StreamSubscription<KeyboardEvent> _onKeyDownSubscription;
  List<Element> ignoreInputFromElements;
  GenericInputHandlingSystem(super.aspect, this.ignoreInputFromElements);

  @override
  void initialize(World world) {
    super.initialize(world);
    _onKeyDownSubscription = window.onKeyDown.listen(handleInput);
    _onKeyUpSubscription = EventStreamProviders.keyUpEvent
        .forTarget(window)
        .listen((event) => handleInput(event, keyDown: false));
  }

  @override
  Future<void> destroy() async {
    await _onKeyDownSubscription.cancel();
    await _onKeyUpSubscription.cancel();
  }

  void handleInput(KeyboardEvent event, {bool keyDown = true}) {
    if (!ignoreInputFromElements.contains(event.target)) {
      keyState[event.keyCode] = keyDown;
      if (!keyDown && (unpress[event.keyCode] ?? false)) {
        unpress[event.keyCode] = false;
      }
      if (preventDefaultKeys.contains(event.keyCode)) {
        event.preventDefault();
      }
    }
  }

  bool get left => isPressed(KeyCode.A) || isPressed(KeyCode.LEFT);
  bool get right => isPressed(KeyCode.D) || isPressed(KeyCode.RIGHT);
  bool get up => isPressed(KeyCode.W) || isPressed(KeyCode.UP);
  bool get down => isPressed(KeyCode.S) || isPressed(KeyCode.DOWN);

  bool isPressed(int keyCode) =>
      (keyState[keyCode] ?? false) && !(unpress[keyCode] ?? false);
}
