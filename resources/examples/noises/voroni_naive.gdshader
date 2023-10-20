shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

vec2 N22(vec2 p) {
    vec3 a = fract(p.xyx * vec3(123.34, 234.34, 345.65));
    a += dot(a, a+34.45);
    return fract(vec2(a.x * a.y, a.y * a.z));
}

void fragment() {
    vec2 uv = vec2(UV.x, 1.-UV.y);
    vec2 st = uv  - vec2(.5); 
    st *= 2.;
    float m = 0.;
    float t = TIME * .2;
    float minDist = 1000.;
    float cellIndex = 0.;
    
    vec3 color = vec3(0.);
    
    vec2 gv = fract(uv*3.);
    vec2 id = floor(uv*3.);
    
    color.rg = gv;
    
	COLOR = vec4(color, 1.);
}