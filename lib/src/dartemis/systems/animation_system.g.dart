// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_system.dart';

// **************************************************************************
// SystemGenerator
// **************************************************************************

abstract class _$AnimationSystem extends EntitySystem {
  late final Mapper<Renderable> renderableMapper;
  _$AnimationSystem() : super(Aspect.empty()..allOf([Renderable]));
  @override
  void initialize() {
    super.initialize();
    renderableMapper = Mapper<Renderable>(world);
  }

  @override
  void processEntities(Iterable<int> entities) {
    final renderableMapper = this.renderableMapper;
    for (final entity in entities) {
      processEntity(entity, renderableMapper[entity]);
    }
  }

  void processEntity(int entity, Renderable renderable);
}
