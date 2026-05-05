shader_type canvas_item;
uniform float intensidad : hint_range(0.0, 1.0) = 0.0;
uniform float tiempo : hint_range(0.0, 100.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 center = vec2(0.5, 0.5);
	
	float dist = distance(uv, center);
	float wave = sin(dist * 30.0 - tiempo * 16.0) * 0.012 * intensidad;
	wave += sin(dist * 17.0 - tiempo * 9.0 + uv.x * 8.0) * 0.006 * intensidad;
	wave += sin(dist * 43.0 - tiempo * 23.0 + uv.y * 5.0) * 0.004 * intensidad;
	wave *= smoothstep(0.8, 0.0, dist);
	uv += normalize(uv - center) * wave;
	
	float aberration = 0.025 * intensidad;
	float r = texture(screen_texture, uv + vec2(aberration, 0.0)).r;
	float g = texture(screen_texture, uv).g;
	float b = texture(screen_texture, uv - vec2(aberration, 0.0)).b;
	vec4 color = vec4(r, g, b, 1.0);
	
	float vignette_base = smoothstep(0.4, 0.85, dist);
	float pulso = sin(tiempo * 6.0) * 0.15 + 0.85;
	float vignette = vignette_base * intensidad * pulso;
	color.rgb *= (1.0 - vignette * 1.2);
	
	COLOR = color;
}