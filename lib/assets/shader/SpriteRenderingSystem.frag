#version 100

precision mediump float;

uniform sampler2D uSheet;
uniform vec2 uSize;
varying vec2 vTexCoord;

void main() {
	vec4 color = texture(uSheet, vTexCoord / uSize);;
	// if (color.a < 1.0) discard;
	gl_FragColor = color;
}