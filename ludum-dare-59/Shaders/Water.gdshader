shader_type canvas_item;

uniform sampler2D mask_texture;
uniform float dim_brightness : hint_range(0.0, 1.0) = 0.4;

void fragment() {
    float visibility = texture(mask_texture, SCREEN_UV).r;
    float brightness = mix(dim_brightness, 1.0, visibility);
    COLOR = vec4(COLOR.rgb * brightness, COLOR.a);
}