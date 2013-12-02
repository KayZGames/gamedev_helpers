part of gamedev_helpers;

class SoundSystem extends EntityProcessingSystem {
  ComponentMapper<Sound> sm;
  AudioHelper helper;
  SoundSystem(this.helper) : super(Aspect.getAspectForAllOf([Sound]));

  initialize() {
    sm = new ComponentMapper<Sound>(Sound, world);
  }

  processEntity(Entity e) {
    helper.playClip(sm.get(e).clipName);
    e.deleteFromWorld();
  }
}