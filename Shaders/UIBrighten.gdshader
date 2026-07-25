shader_type canvas_item;

uniform float brightness : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR.rgb = tex_color.rgb * brightness;
    COLOR.a = tex_color.a;
}