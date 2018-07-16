part of gamedev_helpers;

abstract class GenericInputHandlingSystem extends EntityProcessingSystem {
  /// to prevent scrolling
  final Set<int> preventDefaultKeys = Set<int>.from(
      [KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  final Map<int, bool> keyState = <int, bool>{};
  final Map<int, bool> unpress = <int, bool>{};
  StreamSubscription _onKeyUpSubscription;
  StreamSubscription _onKeyDownSubscription;
  GenericInputHandlingSystem(Aspect aspect) : super(aspect);

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
    keyState[event.keyCode] = keyDown;
    if (!keyDown && unpress[event.keyCode] == true) {
      unpress[event.keyCode] = false;
    }
    if (preventDefaultKeys.contains(event.keyCode)) {
      event.preventDefault();
    }
  }

  bool get left => isPressed(KeyCode.A) || isPressed(KeyCode.LEFT);
  bool get right => isPressed(KeyCode.D) || isPressed(KeyCode.RIGHT);
  bool get up => isPressed(KeyCode.W) || isPressed(KeyCode.UP);
  bool get down => isPressed(KeyCode.S) || isPressed(KeyCode.DOWN);

  bool isPressed(int keyCode) =>
      keyState[keyCode] == true && unpress[keyCode] != true;
}
