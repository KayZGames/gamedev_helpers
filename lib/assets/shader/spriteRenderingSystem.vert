#version 100

uniform mat4 uViewProjection;
attribute vec4 aPosition;
attribute vec2 aTexCoord;
varying vec2 vTexCoord;

void main() {
  gl_Position = uViewProjection * aPosition;
  vTexCoord = aTexCoord;
}