shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))*
        4358.5453123);
}

vec2 rotate2D (vec2 _st, float _angle) {
    _st -= 0.5;
    _st =  mat2(vec2(cos(_angle),-sin(_angle)),
                vec2(sin(_angle),cos(_angle))) * _st;
    _st += 0.5;
    return _st;
}

vec2 tile (vec2 _st, float _zoom) {
    _st *= _zoom;
    return fract(_st);
}

vec2 rotateTilePattern(vec2 _st){

    //  Scale the coordinate system by 2x2
    _st *= 2.0;

    //  Give each cell an index number
    //  according to its position
    float index = 0.0;
    index += step(1., mod(_st.x,2.0));
    index += step(1., mod(_st.y,2.0))*2.0;

    //  2   |   3
    //--------------
    //  0   |   1

    // Make each cell between 0.0 - 1.0
    _st = fract(_st);

    // Rotate each cell according to the index
    if(index == 1.0){
        //  Rotate cell 1 by 90 degrees
        _st = rotate2D(_st,PI*0.5);
    } else if(index == 2.0){
        //  Rotate cell 2 by -90 degrees
        _st = rotate2D(_st,PI*-0.5);
    } else if(index == 3.0){
        //  Rotate cell 3 by 180 degrees
        _st = rotate2D(_st,PI);
    }

    return _st;
}

void fragment() {
	vec2 st = vec2(UV.x, 1.-UV.y);
	vec2 mouse = vec2(mouse_pos.x, 1.-mouse_pos.y);

	vec3 color = vec3(0.);
    
    //st = tile(st,3.0);
    // st = rotateTilePattern(st);
    // Make more interesting combinations
    st = tile(st,2.);
    st = rotate2D(st,-PI*TIME*0.25);
    st = rotateTilePattern(st*2.);
    st = rotate2D(st,PI*TIME*0.25);
    
    color = vec3(step(st.x,st.y));

	COLOR = vec4(color, 1.);
}