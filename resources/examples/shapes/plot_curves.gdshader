shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

float plot_line(vec2 p) {
    return smoothstep(0., .01, abs(p.x -p.y));
}

float plot(vec2 st, float pct){
  return  smoothstep( pct-0.02, pct, st.y) - smoothstep( pct, pct+0.02, st.y);
}

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);
    
    st -= vec2(.5);
    st *= 5.;

	vec3 color = vec3(0.);
    
    float y = pow(st.x, 5.);
    y = exp(st.x - 1.);
    y = exp2(st.x - 1.);
    y = log(st.x);
    y = log2(st.x);
    color = vec3(plot(st, y));

	COLOR = vec4(color, 1.);
}