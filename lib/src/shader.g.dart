// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shader.dart';

// **************************************************************************
// AssetGenerator
// **************************************************************************

enum GhShaders {
  particleRenderingSystem$frag,
  particleRenderingSystem$vert,
  spriteRenderingSystem$frag,
  spriteRenderingSystem$vert
}

const _ghShaders$asset = {
  GhShaders.particleRenderingSystem$frag: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/particleRenderingSystem.frag',
      r'''#version 300 es

precision mediump float;
in vec4 vColor;
out vec4 fragColor;

void main() {
  fragColor = vColor;
}''')),
  GhShaders.particleRenderingSystem$vert: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/particleRenderingSystem.vert',
      r'''#version 300 es

uniform mat4 uViewProjection;
in vec2 aPosition;
in float aRadius;
in vec4 aColor;
out vec4 vColor;

void main() {
    gl_Position = uViewProjection * vec4(aPosition, 0.0, 1.0);
    gl_PointSize = aRadius;
    vColor = aColor;
}''')),
  GhShaders.spriteRenderingSystem$frag: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/spriteRenderingSystem.frag',
      r'''#version 300 es

precision mediump float;

uniform sampler2D uSheet;
uniform vec2 uSize;
in vec2 vTexCoord;
out vec4 fragColor;

void main() {
	vec4 color = texture(uSheet, vTexCoord / uSize);;
	// if (color.a < 1.0) discard;
	fragColor = color;
}''')),
  GhShaders.spriteRenderingSystem$vert: TextAsset(AssetData(
      r'gamedev_helpers|assets/shader/spriteRenderingSystem.vert',
      r'''#version 300 es

uniform mat4 uViewProjection;
in vec4 aPosition;
in vec2 aTexCoord;
out vec2 vTexCoord;

void main() {
  gl_Position = uViewProjection * aPosition;
  vTexCoord = aTexCoord;
}'''))
};
