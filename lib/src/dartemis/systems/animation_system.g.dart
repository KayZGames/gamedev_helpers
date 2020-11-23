// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_system.dart';

// **************************************************************************
// SystemGenerator
// **************************************************************************

abstract class _$AnimationSystem extends EntityProcessingSystem {
  Mapper<Renderable> renderableMapper;
  _$AnimationSystem() : super(Aspect.empty()..allOf([Renderable]));
  @override
  void initialize() {
    super.initialize();
    renderableMapper = Mapper<Renderable>(world);
  }
}
