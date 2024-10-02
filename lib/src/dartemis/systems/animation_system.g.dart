// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_system.dart';

// **************************************************************************
// SystemGenerator
// **************************************************************************

abstract class _$AnimationSystem extends EntitySystem {
  late final Mapper<Renderable> renderableMapper;
  _$AnimationSystem({super.group, super.passive})
      : super(Aspect(
          allOf: [Renderable],
        ));
  @override
  void initialize(World world) {
    super.initialize(world);
    renderableMapper = Mapper<Renderable>(world);
  }

  @override
  void processEntities(Iterable<Entity> entities) {
    final renderableMapper = this.renderableMapper;
    for (final entity in entities) {
      processEntity(entity, renderableMapper[entity]);
    }
  }

  void processEntity(Entity entity, Renderable renderable);
}
