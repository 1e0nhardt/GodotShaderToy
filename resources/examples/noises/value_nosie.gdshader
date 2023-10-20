shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

float N21(vec2 p) {
    return fract(sin(p.x * 100. + p.y * 6574.) * 5647.); 
}

float SmoothNoise(vec2 p) {
    vec2 lv = fract(p);
    vec2 id = floor(p);
    lv = lv*lv*(3. - 2.*lv);
    
    float bl = N21(id);
    float br = N21(id + vec2(1., 0.));
    float b = mix(bl, br, lv.x);
    
    float tl = N21(id + vec2(0., 1.));
    float tr = N21(id + vec2(1., 1.));
    float t = mix(tl, tr, lv.x);
    
    return mix(b, t, lv.y);
}

void fragment() {
    vec2 st = UV;
    st.y = 1. - st.y;
    st = st + TIME * .1;
    
    float c = SmoothNoise(st * 4.);
    c += SmoothNoise(st * 8.) * .5;
    c += SmoothNoise(st * 16.) * .25;
    c += SmoothNoise(st * 32.) * .125;
    c += SmoothNoise(st * 65.) * .0625;
    c /= 2.;
    
    vec3 color = vec3(c);
	COLOR = vec4(color, 1.);
}