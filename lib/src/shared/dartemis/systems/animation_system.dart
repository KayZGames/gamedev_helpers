part of gamedev_helpers_shared;

@Generate(EntityProcessingSystem, allOf: const [Renderable])
class AnimationSystem extends _$AnimationSystem {
  @override
  void processEntity(Entity entity) {
    renderableMapper[entity].time += world.delta;
  }
}
