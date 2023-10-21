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

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);

	vec3 color = vec3(0.);
    
    vec3 colorA = vec3(0.2);
    vec3 colorB = vec3(1.);
    vec3 colorC = rgb(170, 66, 24);
    vec3 colorD = rgb(253, 245, 196);
    vec3 colorBlue = rgb(82, 82, 136);
    
    color = mix(color, colorA, step(0., st.x) - step(.2, st.x));
    color = mix(color, colorB, step(0.2, st.x) - step(.4, st.x));
    color = mix(color, colorC, step(0.4, st.x) - step(.6, st.x));
    color = mix(color, colorD, step(0.6, st.x) - step(.8, st.x));
    color = mix(color, colorBlue, step(0.8, st.x) - step(1.0, st.x));
    
	COLOR = vec4(color, 1.);
}