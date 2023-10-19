#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 mouse_pos;
uniform float u_time;

void fragment() {
	vec4 color = vec4(sin(u_time * 2.), cos(u_time), 1.0, 1.0);
	gl_FragColor = color;
}