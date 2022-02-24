#version 300 es

precision mediump float;

uniform sampler2D uSheet;
uniform vec2 uSize;
in vec2 vTexCoord;
out vec4 fragColor;

void main() {
	vec4 color = texture(uSheet, vTexCoord / uSize);;
	// if (color.a < 1.0) discard;
	fragColor = color;
}