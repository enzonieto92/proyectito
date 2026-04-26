shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 viewport_size = vec2(1152.0, 648.0); // tu resolución acá

const int pixel_size = 6;

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);
	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;
	COLOR = texture(screen_texture, vec2(x, y) / viewport_size);
}