// ------------------------------------------------------------------
// AGUA ANIMADA DEL MAPA
// "mascara" marca en rojo el agua (ríos) y en verde las cascadas.
// El agua ondula y brilla; las cascadas tienen franjas que bajan.
// ------------------------------------------------------------------
shader_type canvas_item;

uniform sampler2D mascara : filter_nearest;
uniform float fuerza_ondas = 1.0;
uniform float velocidad_cascada = 9.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	vec4 m = texture(mascara, UV);
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec2 p = UV / px;

	if (m.r > 0.5) {
		// Ondas: tomamos el color de un pixel vecino que se mueve con el tiempo
		vec2 desplazamiento = vec2(sin(TIME * 1.6 + p.y * 0.22), cos(TIME * 1.3 + p.x * 0.18)) * px * fuerza_ondas;
		if (texture(mascara, UV + desplazamiento).r > 0.5) {
			c = texture(TEXTURE, UV + desplazamiento);
		}
		// Brillos sobre el agua
		float b = sin(p.x * 0.31 + p.y * 0.17 + TIME * 1.8) * sin(p.y * 0.43 - TIME * 1.1 + p.x * 0.05);
		c.rgb += vec3(0.18, 0.28, 0.38) * pow(max(b, 0.0), 10.0);
	}

	if (m.g > 0.5) {
		float franja = 0.5 + 0.5 * sin(p.y * 0.7 - TIME * velocidad_cascada + sin(p.x * 0.9) * 2.0);
		c.rgb += vec3(0.10, 0.14, 0.18) * franja;
	}

	COLOR = c;
}
