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
    vec2 st = uv * 8.; 
    //st *= 2.;
    float m = 0.;
    float t = TIME * .5;
    float minDist = 1000.;
    float cellIndex = 0.;
    
    vec3 color = vec3(0.);
    vec2 gv = fract(st)  - vec2(.5);
    vec2 id = floor(st);
    
    for (float y=-1.; y <=1.; y++) { // -1, 0, 1
        for (float x=-1.; x<=1.; x++) {
            vec2 offs = vec2(x, y);
            vec2 n = N22(id + offs);
            vec2 p = offs + sin(n*t) * .5;
            p -= gv;
            float ed = length(p);
            float md = abs(p.x) + abs(p.y);
            float d = mix(ed, md, .5 + .5*sin(t));
            if (d < minDist) {
                minDist = d;
            }
            m += smoothstep(.02, .01, d);
        }  
    }
    
    color = vec3(minDist);
    color += m;
    
	COLOR = vec4(color, 1.);
}