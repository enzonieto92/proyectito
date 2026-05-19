shader_type canvas_item;

// --- Tu shader original de pixelación ---
uniform sampler2D screen_tex : hint_screen_texture;
uniform int pixel_size : hint_range(1, 32) = 6;

// --- Efectos PS1 adicionales ---
uniform int   color_bits         : hint_range(2, 8, 1) = 5;    // 5 = PS1 real (32 niveles por canal)
uniform float dither_strength    : hint_range(0.0, 1.0) = 0.4; // Intensidad del dithering Bayer
uniform float vertex_jitter      : hint_range(0.0, 2.0) = 0.6; // Wobble affine (0 = off)
uniform bool  enable_dither      = true;
uniform bool  enable_color_crush = true;
uniform bool  enable_jitter      = true;

// --- Matriz Bayer 4x4 ---
float bayer4x4(ivec2 pos) {
    int x = pos.x % 4;
    int y = pos.y % 4;
    int[16] m = int[16](
         0,  8,  2, 10,
        12,  4, 14,  6,
         3, 11,  1,  9,
        15,  7, 13,  5
    );
    return float(m[y * 4 + x]) / 16.0 - 0.5;
}

// --- Cuantización de color ---
vec3 crush_color(vec3 col, int bits) {
    float steps = float((1 << bits) - 1);
    return round(col * steps) / steps;
}

void fragment() {
    vec2 frag  = FRAGCOORD.xy;
    vec2 block = vec2(float(pixel_size));

    // Wobble affine: snap a grid de punto fijo antes de pixelar,
    // simula los enteros de 12.4 bits de la GTE de la PS1.
    // Con vertex_jitter = 0 o enable_jitter = false se comporta
    // exactamente igual que tu shader original.
    vec2 snapped = frag;
    if (enable_jitter && vertex_jitter > 0.0) {
        float precision = block.x / vertex_jitter;
        snapped = round(frag / precision) * precision;
    }

    // Tu lógica original de pixelado (sin cambios)
    vec2 blocked = (floor(snapped / block) + 0.5) * block;
    vec2 uv      = blocked / vec2(textureSize(screen_tex, 0));
    vec3 col     = texture(screen_tex, uv).rgb;

    // Dithering Bayer — opera por bloque para respetar el tamaño de pixel
    if (enable_dither && dither_strength > 0.0) {
        ivec2 block_pos = ivec2(floor(frag / block));
        float threshold = bayer4x4(block_pos) * dither_strength * 0.12;
        col = clamp(col + vec3(threshold), 0.0, 1.0);
    }

    // Paleta aplastada
    if (enable_color_crush) {
        col = crush_color(col, color_bits);
    }

    COLOR = vec4(col, 1.0);
}