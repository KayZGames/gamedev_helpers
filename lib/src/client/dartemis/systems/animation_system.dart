part of gamedev_helpers;

@Generate(EntityProcessingSystem, allOf: [Renderable])
class AnimationSystem extends _$AnimationSystem {
  @override
  void processEntity(Entity entity) {
    renderableMapper[entity].time += world.delta;
  }
}
