import 'package:dartemis/dartemis.dart';

import '../components.dart';

part 'animation_system.g.dart';

@Generate(
  EntityProcessingSystem,
  allOf: [
    Renderable,
  ],
)
class AnimationSystem extends _$AnimationSystem {
  @override
  void processEntity(Entity entity, Renderable renderable) {
    renderable.time += world.delta;
  }
}
