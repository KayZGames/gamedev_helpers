// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assets.dart';

// **************************************************************************
// BundleGenerator
// **************************************************************************

const String _fShaderParticleRendering$content = r'''#version 100

precision mediump float;
varying vec4 vColor;

void main() {
  gl_FragColor = vColor;
}''';

const String _vShaderParticleRendering$content = r'''#version 100

uniform mat4 uViewProjection;
attribute vec2 aPosition;
attribute float aRadius;
attribute vec4 aColor;
varying vec4 vColor;

void main() {
    gl_Position = uViewProjection * vec4(aPosition, 0.0, 1.0);
    gl_PointSize = aRadius;
    vColor = aColor;
}''';

const String _fShaderSpriteRendering$content = r'''#version 100

precision mediump float;

uniform sampler2D uSheet;
uniform vec2 uSize;
varying vec2 vTexCoord;

void main() {
	vec4 color = texture2D(uSheet, vTexCoord / uSize);;
	// if (color.a < 1.0) discard;
	gl_FragColor = color;
}''';

const String _vShaderSpriteRendering$content = r'''#version 100

uniform mat4 uViewProjection;
attribute vec4 aPosition;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
  gl_Position = uViewProjection * aPosition;
  vTexCoord = aTexCoord;
}''';
