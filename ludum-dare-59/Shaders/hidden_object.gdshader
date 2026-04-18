shader_type canvas_item;

uniform sampler2D mask_texture : filter_linear;
uniform float edge_softness : hint_range(0.0, 0.1) = 0.02;
uniform float min_alpha : hint_range(0.0, 1.0) = 0.05;
uniform float min_brightness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    float visibility = texture(mask_texture, SCREEN_UV).r;
    visibility = smoothstep(0.0, edge_softness + 0.001, visibility);
    COLOR.rgb *= mix(min_brightness, 1.0, visibility);
    COLOR.a *= mix(min_alpha, 1.0, visibility);
}