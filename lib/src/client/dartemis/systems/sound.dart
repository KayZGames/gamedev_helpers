part of gamedev_helpers;

class SoundSystem extends EntityProcessingSystem {
  Mapper<Sound> sm;
  AudioHelper helper;
  SoundSystem(this.helper) : super(Aspect.getAspectForAllOf([Sound]));

  initialize() {
    sm = new Mapper<Sound>(Sound, world);
  }

  processEntity(Entity e) {
    helper.playClip(sm[e].clipName);
    e.deleteFromWorld();
  }
}