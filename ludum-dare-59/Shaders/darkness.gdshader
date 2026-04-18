shader_type canvas_item;

uniform sampler2D mask_texture;
uniform vec4 fog_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float edge_softness : hint_range(0.0, 0.1) = 0.02;

void fragment() {
    float visibility = texture(mask_texture, UV).r;
    visibility = smoothstep(0.0, edge_softness + 0.001, visibility);
    COLOR = mix(fog_color, vec4(0.0), visibility);
}