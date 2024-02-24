RSRC                 	   Resource            ��������   GodotShaderToyProject                                             	      resource_local_to_scene    resource_name    script    image_text    common 	   channel0 	   channel1 	   channel2 	   channel3       Script    res://resources/gstp.gd ��������      local://Resource_i4x21 d      	   Resource                         shader_type canvas_item;
//
// uniform vec2 iMouse: 归一化后的鼠标位置，原点为左上角。
// uniform vec2 iResolution: 画布分辨率。显示在左边 wxh。
// uniform float iTime: 左边显示的时间，而非内置的TIME。 
//
//
//END
uniform vec2 iResolution;
uniform float iTime;
uniform vec2 iMouse;

void fragment() {
	vec2 uv = flipY(UV);
    uv -= 0.5;
    uv.x *= iResolution.x/iResolution.y;

	vec3 col = iMouse.x*.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    
	COLOR = vec4(col, 1.);
}       �  //
//
// uniform vec2 mouse_pos: 归一化后的鼠标位置，原点为左上角。
// uniform vec2 iResolution: 画布分辨率。显示在左边 wxh。
// uniform float iTime: 左边显示的时间，而非内置的TIME。 
//
//END
vec2 flipY(vec2 uv){
    uv.y = 1. - uv.y;
    return uv;
}

mat2 rot(float a){
    return mat2(
        vec2(cos(a), -sin(a)),
        vec2(sin(a), cos(a))
    );
}                         RSRC