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
    float y = step(.5, st.x);
    y = smoothstep(.3, .7, st.x);
    // smooth line
    y = smoothstep(.3, .6, st.x) - smoothstep(.6, .9, st.x); 
    // line
    y = step(.3, st.x) - step(.5, st.x);
    color = vec3(y);

	COLOR = vec4(color, 1.);
}