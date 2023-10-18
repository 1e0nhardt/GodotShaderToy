shader_type canvas_item;

uniform vec2 mouse_pos;

void fragment() {
	vec4 color = vec4(0.1, 0.2, 0.3, 1.0);
	COLOR = vec4(mouse_pos, 1., 1.);
}
