shader_type canvas_item;

uniform sampler2D inTex;
uniform int iFrame;


bool close(float a, float b) {
    return abs(a - b) < 0.00001;
}

void fragment() {
    vec3 col = vec3(0);
    
    if (iFrame == 0) {
        // 读取输入，并预处理(需要分割好的图片，a通道: 背景0，前景1)
        col = texture(inTex, UV).a > .9 ? vec3(UV, 0) : vec3(0);
    }
    //else if (iFrame >= 24) {
        //vec2 seed_pos = texture(TEXTURE, UV).xy;
        //float d = distance(UV, seed_pos);
        ////float thickness = 0.03;
        ////col += smoothstep(thickness, thickness - 0.005, d);
        ////col *= texture(inTex, UV).rgb;
        //col = vec3(seed_pos, d);
    //}
    else {
        float level = clamp(float(iFrame), 1., 12.);
        // 支持的最大图片尺寸为4096
        float stepwidth = exp2(12.0 - level); 
        
        float best_dist = 999999.0;
        vec2 best_coord = vec2(0.0);
        for (float y = -1.; y <= 1.; ++y) {
            for (float x = -1.; x <= 1.; ++x) {
                vec2 fc = UV + vec2(x,y) * stepwidth * SCREEN_PIXEL_SIZE;
   	            vec2 ntc = texture(TEXTURE, fc).xy;
                float d = length(ntc - UV);
                if (!close(ntc.x, 0.) && !close(ntc.y, 0.) && (d < best_dist)) {
                    best_dist = d;
                    best_coord = ntc;
                }
            }
        }
        col = vec3(best_coord, 0.); 
    }
	COLOR = vec4(col, 1.);
}