shader_type canvas_item;
uniform float intensidad : hint_range(0.0, 1.0) = 0.0;
uniform float tiempo : hint_range(0.0, 100.0) = 0.0;
uniform float radio_interno : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Toma un valor continuo y lo "cuantiza" suavemente en escalones
float stepped(float x, float pasos) {
	float s = x * pasos;
	// mezcla entre el escalón actual y el siguiente con una transición corta
	float base = floor(s);
	float t = fract(s);
	t = smoothstep(0.0, 0.25, t); // transición dura: solo 25% del paso es curva
	return (base + t) / pasos;
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5, 0.5);
	
	float dist = distance(uv, center);
	float fade_interior = smoothstep(radio_interno, radio_interno + 0.05, dist);

	float wave = sin(dist * 30.0 - tiempo * 16.0) * 0.012 * intensidad;
	wave += sin(dist * 17.0 - tiempo * 9.0 + uv.x * 8.0) * 0.006 * intensidad;
	wave += sin(dist * 43.0 - tiempo * 23.0 + uv.y * 5.0) * 0.004 * intensidad;
	wave *= smoothstep(0.8, 0.0, dist);
	wave *= fade_interior;
	uv += normalize(uv - center) * wave;

	// --- Aberración errática con movimiento angular ---

	// Envolvente: producto de senos -> toca cero periódicamente
	// sign() + pow() para que los valles sean caídas abruptas, no curvas
	float e_raw = abs(sin(tiempo * 1.3)) 
	            * abs(sin(tiempo * 0.7 + 1.0)) 
	            * abs(sin(tiempo * 2.1 + 2.5));
	// Acentúa picos: valores altos se mantienen, bajos caen rápido
	float envolvente = pow(e_raw, 0.25);
	// Escalona la envolvente para que "salte" entre niveles en vez de fluir
	envolvente = stepped(envolvente, 6.0);

	// Ángulo de aberración: suma de senos elevados a potencia impar
	// -> se queda más tiempo en los extremos, cruza el centro rápido
	float angulo_raw = sin(tiempo * 2.3)  * 0.5
	                 + sin(tiempo * 5.11) * 0.3
	                 + sin(tiempo * 11.7) * 0.2;
	// Potencia impar preserva el signo y aplana la zona media
	float angulo = sign(angulo_raw) * pow(abs(angulo_raw), 0.4) * 3.14159;

	vec2 aber_dir = vec2(cos(angulo), sin(angulo));
	float aberration = 0.025 * intensidad * envolvente;

	float r = texture(screen_texture, uv + aber_dir * aberration).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - aber_dir * aberration).b;
	vec4 color = vec4(r, g, b, 1.0);
	
	float vignette_base = smoothstep(0.4, 0.85, dist);
	float pulso = sin(tiempo * 6.0) * 0.15 + 0.85;
	float vignette = vignette_base * intensidad * pulso;
	color.rgb *= (1.0 - vignette * 1.2);
	
	COLOR = color;
}