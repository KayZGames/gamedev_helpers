part of gamedev_helpers_shared;

class TweeningSystem extends VoidEntitySystem {
  @override
  void processSystem() {
    tweenManager.update(world.delta);
  }
}
