part of gamedev_helpers;

abstract class GenericInputHandlingSystem extends EntityProcessingSystem {
  /// to prevent scrolling
  var preventDefaultKeys = new Set.from([KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT, KeyCode.SPACE]);
  var keyState = <int, bool>{};
  GenericInputHandlingSystem(Aspect aspect) : super(aspect);

  @override
  void initialize() {
    window.onKeyDown.listen((event) => handleInput(event, true));
    window.onKeyUp.listen((event) => handleInput(event, false));
  }

  void handleInput(KeyboardEvent event, bool pressed) {
    keyState[event.keyCode] = pressed;
    if (preventDefaultKeys.contains(event.keyCode)) {
      event.preventDefault();
    }
  }
}