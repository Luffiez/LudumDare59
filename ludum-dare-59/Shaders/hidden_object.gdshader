shader_type canvas_item;

uniform sampler2D mask_texture : filter_linear;
uniform float edge_softness : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    float visibility = texture(mask_texture, SCREEN_UV).r;
    visibility = smoothstep(0.0, edge_softness + 0.001, visibility);
    COLOR.a *= visibility;
}