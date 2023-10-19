shader_type canvas_item;

uniform vec2 mouse_pos;

void fragment() {
    COLOR = vec4(mouse_pos, 1., 1.);
}
