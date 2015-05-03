part of gamedev_helpers;

abstract class GenericInputHandlingSystem extends EntityProcessingSystem {
  /// to prevent scrolling
  var preventDefaultKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  var keyState = <int, bool>{};
  var unpress = <int, bool>{};
  GenericInputHandlingSystem(Aspect aspect) : super(aspect);

  @override
  void initialize() {
    window.onKeyDown.listen((event) => handleInput(event, true));
    window.onKeyUp.listen((event) => handleInput(event, false));
  }

  void handleInput(KeyboardEvent event, bool pressed) {
    keyState[event.keyCode] = pressed;
    if (!pressed && unpress[event.keyCode] == true) {
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

  bool isPressed(int keyCode) => keyState[keyCode] == true && unpress[keyCode] != true;
}