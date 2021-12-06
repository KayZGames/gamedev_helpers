import 'dart:async';
import 'dart:html';

import 'package:dartemis/dartemis.dart';

abstract class GenericInputHandlingSystem extends EntityProcessingSystem {
  /// to prevent scrolling
  final Set<int> preventDefaultKeys = <int>{
    KeyCode.UP,
    KeyCode.DOWN,
    KeyCode.LEFT,
    KeyCode.RIGHT,
    KeyCode.SPACE
  };
  final Map<int, bool> keyState = <int, bool>{};
  final Map<int, bool> unpress = <int, bool>{};
  late final StreamSubscription _onKeyUpSubscription;
  late final StreamSubscription _onKeyDownSubscription;
  List<Element> ignoreInputFromElements;
  GenericInputHandlingSystem(Aspect aspect, this.ignoreInputFromElements)
      : super(aspect);

  @override
  void initialize() {
    _onKeyDownSubscription = window.onKeyDown.listen(handleInput);
    _onKeyUpSubscription =
        window.onKeyUp.listen((event) => handleInput(event, keyDown: false));
  }

  @override
  void destroy() {
    _onKeyDownSubscription.cancel();
    _onKeyUpSubscription.cancel();
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
