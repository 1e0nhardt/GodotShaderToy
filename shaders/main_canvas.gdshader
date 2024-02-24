shader_type canvas_item;

void fragment(){
    vec3 col = vec3(UV.x);
    COLOR = vec4(col, 1.0);
}