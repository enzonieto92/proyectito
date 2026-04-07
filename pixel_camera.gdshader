shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture;

const int pixel_size = 8;

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);

	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

	vec2 uv = vec2(x, y) / VIEWPORT_SIZE;

	vec3 color = texture(screen_tex, uv).rgb;

	ALBEDO = color;
}
