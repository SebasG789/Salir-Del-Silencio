// ------------------------------------------------------------------
// NIEBLA EN MOVIMIENTO
// Nubes suaves hechas con ruido que se desplazan lentamente.
// ------------------------------------------------------------------
shader_type canvas_item;

uniform vec4 color_niebla : source_color = vec4(0.78, 0.82, 0.92, 1.0);
uniform float densidad = 0.3;
uniform float velocidad = 0.02;
uniform vec2 tamano = vec2(2067.0, 761.0);
uniform float escala = 140.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float ruido(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * ruido(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 p = UV * tamano / escala;
	float n = fbm(p + vec2(TIME * velocidad * 10.0, TIME * velocidad * 3.0));
	n *= fbm(p * 0.6 - vec2(TIME * velocidad * 6.0, 0.0) + 7.3);
	float a = smoothstep(0.18, 0.5, n) * densidad;
	COLOR = vec4(color_niebla.rgb, a);
}
