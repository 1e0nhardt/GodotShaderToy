shader_type canvas_item;

uniform float blue;
uniform vec3 a : source_color;
//
void fragment() {
	vec4 color = vec4(0.3, 0.1, 0.2, 1.0);
	COLOR = color;
}
