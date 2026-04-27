shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform int pixel_size : hint_range(1, 32) = 6;

void fragment() {
    vec2 frag    = FRAGCOORD.xy;
    vec2 block   = vec2(float(pixel_size));
    vec2 snapped = (floor(frag / block) + 0.5) * block;
    vec2 uv      = snapped / vec2(textureSize(screen_tex, 0));

    COLOR = texture(screen_tex, uv);
}
