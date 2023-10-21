shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

float plot(vec2 st, float pct) {
    return smoothstep(pct - .01, pct, st.y) - smoothstep(pct, pct + .01, st.y);
}

vec3 rgb(int r, int g, int b) {
    return vec3(float(r)/255., float(g)/255., float(b)/255.);
}

float ring(vec2 st, float r) {
    float c = length(st);
    return smoothstep(r - .05, r, c) - smoothstep(r, r + .05, c);
}

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);

	vec3 color = vec3(0.);
    
    st -= vec2(.5, 0.);
    float c = ring(st, .35);
    color = mix(color, vec3(1., 0., 0.), c);
    c = ring(st, .4);
    color = mix(color, vec3(0., 1., 0.), c);
    c = ring(st, .45);
    color = mix(color, vec3(0., 0., 1.), c);
    c = ring(st, .5);
    color = mix(color, vec3(1., 0., 1.), c);
    
	COLOR = vec4(color, 1.);
}