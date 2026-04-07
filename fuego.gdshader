shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled;

void fragment() {
    ALBEDO = COLOR.rgb;
    ALPHA = COLOR.a;
}