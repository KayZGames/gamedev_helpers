#version 100

precision mediump float;
attribute vec4 vColor;

void main() {
  gl_FragColor = vColor;
}