shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);

	vec3 color = vec3(0.);

	COLOR = vec4(color, 1.);
}