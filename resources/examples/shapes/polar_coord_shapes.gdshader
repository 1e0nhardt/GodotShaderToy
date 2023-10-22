shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

float plot(float x, float pct){
  return  smoothstep( pct-0.02, pct, x) - smoothstep( pct, pct+0.02, x);
}

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);
    
    vec2 pos = vec2(0.5)-st;
    pos *= 3.;
    float r = length(pos)*2.0;
    float a = atan(pos.y,pos.x);

	vec3 color = vec3(0.);
    
    float f = cos(a*3.);
    // f = abs(cos(a*3.));
    // f = abs(cos(a*2.5))*.5+.3;
    // f = abs(cos(a*12.)*sin(a*3.))*.8+.1;
    // f = smoothstep(-.5,1., cos(a*10.))*0.2+0.5;
    f = 1. + sin(a);
    f = cos(a*4.);
    f = a;

    color = vec3( 1.-smoothstep(f,f+0.02,r) );
//    float c = plot(r, f);
//    color = vec3(c);

	COLOR = vec4(color, 1.);
}