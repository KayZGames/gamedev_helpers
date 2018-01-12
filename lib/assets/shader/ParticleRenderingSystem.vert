#version 300 es

uniform mat4 uViewProjection;
in vec2 aPosition;
in vec4 aColor;
out vec4 vColor;

void main() {
    gl_Position = uViewProjection * vec4(aPosition, 0.0, 1.0);
    gl_PointSize = 1.0;
    vColor = aColor;
}