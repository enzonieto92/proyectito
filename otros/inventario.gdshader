shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 20.0) = 6.0;
uniform float blur_progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 size = (blur_amount * blur_progress) / vec2(textureSize(screen_texture, 0));
    vec4 color = vec4(0.0);
    float total = 0.0;
    
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            float weight = 1.0 - length(vec2(float(x), float(y))) / 5.0;
            weight = max(weight, 0.0);
            color += texture(screen_texture, SCREEN_UV + vec2(float(x), float(y)) * size) * weight;
            total += weight;
        }
    }
    
    COLOR = color / total;
}