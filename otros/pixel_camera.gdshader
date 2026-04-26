shader_type spatial;
render_mode unshaded, depth_draw_never, depth_test_disabled;

uniform sampler2D screen_tex : hint_screen_texture;

uniform int pixel_size : hint_range(1, 32) = 6;  // slider en el Inspector


void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);

	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

	vec2 uv = vec2(x, y) / VIEWPORT_SIZE;

	vec3 color = texture(screen_tex, uv).rgb;

	ALBEDO = color;
}
