#version 300 es

uniform mat4 uViewProjection;
in vec4 aPosition;
in vec2 aTexCoord;
out vec2 vTexCoord;

void main() {
  gl_Position = uViewProjection * aPosition;
  vTexCoord = aTexCoord;
}