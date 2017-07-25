part of gamedev_helpers_shared;

class AnimationSystem extends EntityProcessingSystem {
  Mapper<Renderable> rm;

  AnimationSystem() : super(new Aspect.forAllOf([Renderable]));

  @override
  void processEntity(Entity entity) {
    rm[entity].time += world.delta;
  }
}