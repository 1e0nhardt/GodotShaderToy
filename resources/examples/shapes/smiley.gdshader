shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

float Circle(vec2 uv, vec2 p, float r, float blur) {
    float d = length(uv - p);
    float c = smoothstep(r, r-blur, d);
    return c;
}

vec3 rgb(int r, int g, int b) { return vec3(float(r)/255., float(g)/255., float(b)/255.);}

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);
    st -= vec2(.5);

	vec3 color = vec3(0.);
    
    float mask = Circle(st, vec2(0.), .4, .05);
    mask -= Circle(st, vec2(-.13, .15), .1, .02);
    mask -= Circle(st, vec2(.13, .15), .1, .02);
    float smile_mouse = Circle(st, vec2(0.), .3, .02);
    smile_mouse -= Circle(st, vec2(0., .1), .33, .02);
    // smile_mouse有值为负一的部分。
    // step(0., smile_mouse)会因为浮点数比较大小的不确定性导致结果不对
//    mask -= step(0., smile_mouse);

    mask -= (smile_mouse + abs(smile_mouse))/2.;
    
//    color = vec3(smile_mouse);
    color = rgb(255, 244, 0) * mask;
	COLOR = vec4(color, 1.);
}