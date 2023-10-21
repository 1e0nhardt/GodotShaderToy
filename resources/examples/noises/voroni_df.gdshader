shader_type canvas_item;
//
//
//
//
//tag
uniform vec2 mouse_pos;

void fragment() {
    // 将左下设为原点
    vec2 uv = vec2(UV.x, 1.-UV.y);
    vec2 mouse = vec2(mouse_pos.x, 1. - mouse_pos.y);
    
    vec2 st = uv; 
    vec3 color = vec3(0.);
    
    vec2 gv = fract(st)  - vec2(.5);
    vec2 id = floor(st);
    
    vec2 point[5];
    point[0] = vec2(0.83,0.75);
    point[1] = vec2(0.60,0.07);
    point[2] = vec2(0.28,0.64);
    point[3] =  vec2(0.31,0.26);
    point[4] = mouse;
    
    float m_dist = 1.;  // minimum distance

    // Iterate through the points positions
    for (int i = 0; i < 5; i++) {
        float dist = distance(st, point[i]);

        // Keep the closer distance
        m_dist = min(m_dist, dist);
    }

    // Draw the min distance (distance field)
    color += m_dist;
    color -= step(.7,abs(sin(50.0*m_dist)))*.3;
    
	COLOR = vec4(color, 1.);
}