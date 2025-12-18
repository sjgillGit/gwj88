shader_type spatial;

uniform float frequency : hint_range(5.0, 30.0, 0.5) = 20.0;
uniform float band_size = 0.1;
uniform float speed = 1.0;
uniform vec3 color_a : source_color = vec3(1.0, 0.2, 0.2);
uniform vec3 color_b : source_color = vec3(0.2, 0.2, 1.0);

void fragment() {
    vec2 uv = UV;
    uv.y += TIME * speed;

    float wave = sin(uv.y * frequency);
	float band = smoothstep(-band_size, band_size, wave);

    ALBEDO = mix(color_a, color_b, band);
}