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

float band(float t, float start, float end, float blur) {
    float step1 = smoothstep(start-blur, start+blur, t);
    float step2 = smoothstep(end+blur, end-blur, t);
    return step1 * step2;
}

float rect(vec2 uv, float left, float right, float bottom, float top, float blur) {
    float band1 = band(uv.x, left, right, blur);
    float band2 = band(uv.y, bottom, top, blur);
    return band1 * band2;
}

float circle0(vec2 _st, float _radius){
    vec2 dist = _st-vec2(0.5);
	return 1.-smoothstep(_radius-(_radius*0.01), _radius+(_radius*0.01), dot(dist,dist)*4.0);
}

float circle(vec2 _st, float _radius, float blur){
    vec2 dist = _st-vec2(0.5);
	return 1.-smoothstep(_radius-blur, _radius+blur, dot(dist,dist)*4.0);
}

float polygon(vec2 uv, float N, float r) {
    float angle = atan(uv.y, uv.x) + PI;
    float slice = 2. * PI / N;
    return smoothstep(r + r*.01, r-r*.01, cos(floor(0.5 + angle / slice) * slice - angle) * length(uv));
}

float remap01(float a, float b, float t) {
    return (t-a)/(b-a);
}

float remap(float a, float b, float c, float d, float t) {
    return remap01(a, b, t) * (d-c) + c;
}

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);
    vec3 color = vec3(0.);
    
    st -= vec2(.5);
    st *= 2.;
    
    float d = 0.;
    
//    d = distance(abs(st), vec2(.3));
    d = length(st);
//    d = length(min(abs(st) - vec2(.3), 0.));
//    d = length(max(abs(st) - vec2(.3), 0.));
    
//    d = fract(d * 10.);
//    d = step( .2, d);
    
    color = vec3(d);

	COLOR = vec4(color, 1.);
}