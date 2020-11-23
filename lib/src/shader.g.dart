// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shader.dart';

// **************************************************************************
// BundleGenerator
// **************************************************************************

enum Shaders {
  particleRenderingSystem$frag,
  particleRenderingSystem$vert,
  spriteRenderingSystem$frag,
  spriteRenderingSystem$vert
}
const _shaders$asset = {
  Shaders.particleRenderingSystem$frag: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/particleRenderingSystem.frag',
      r'''#version 100

precision mediump float;
varying vec4 vColor;

void main() {
  gl_FragColor = vColor;
}''')),
  Shaders.particleRenderingSystem$vert: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/particleRenderingSystem.vert',
      r'''#version 100

uniform mat4 uViewProjection;
attribute vec2 aPosition;
attribute float aRadius;
attribute vec4 aColor;
varying vec4 vColor;

void main() {
    gl_Position = uViewProjection * vec4(aPosition, 0.0, 1.0);
    gl_PointSize = aRadius;
    vColor = aColor;
}''')),
  Shaders.spriteRenderingSystem$frag: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/spriteRenderingSystem.frag',
      r'''#version 100

precision mediump float;

uniform sampler2D uSheet;
uniform vec2 uSize;
varying vec2 vTexCoord;

void main() {
	vec4 color = texture2D(uSheet, vTexCoord / uSize);;
	// if (color.a < 1.0) discard;
	gl_FragColor = color;
}''')),
  Shaders.spriteRenderingSystem$vert: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/spriteRenderingSystem.vert',
      r'''#version 100

uniform mat4 uViewProjection;
attribute vec4 aPosition;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
  gl_Position = uViewProjection * aPosition;
  vTexCoord = aTexCoord;
}'''))
};
