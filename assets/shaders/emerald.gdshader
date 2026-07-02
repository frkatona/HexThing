shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_disabled, diffuse_burley, specular_schlick_ggx;

// Core appearance
uniform vec4 emerald_color : source_color = vec4(0.015, 0.48, 0.22, 1.0);
uniform vec4 edge_color : source_color = vec4(0.16, 1.0, 0.55, 1.0);
uniform float opacity : hint_range(0.05, 1.0, 0.01) = 0.72;
uniform float roughness : hint_range(0.0, 1.0, 0.01) = 0.12;
uniform float metallic : hint_range(0.0, 1.0, 0.01) = 0.05;
uniform float specular : hint_range(0.0, 1.0, 0.01) = 0.9;

// Gem depth and rim response
uniform float fresnel_power : hint_range(0.5, 8.0, 0.1) = 3.2;
uniform float edge_intensity : hint_range(0.0, 4.0, 0.05) = 1.35;
uniform float absorption : hint_range(0.0, 3.0, 0.05) = 0.85;
uniform float internal_glow : hint_range(0.0, 3.0, 0.05) = 0.22;

// Facet variation and animated sparkle
uniform float facet_contrast : hint_range(0.0, 1.0, 0.01) = 0.28;
uniform float facet_scale : hint_range(1.0, 40.0, 0.5) = 12.0;
uniform float sparkle_strength : hint_range(0.0, 3.0, 0.05) = 0.45;
uniform float sparkle_speed : hint_range(0.0, 5.0, 0.05) = 0.65;

varying vec3 object_position;

void vertex() {
	object_position = VERTEX;
}

void fragment() {
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	float fresnel = pow(1.0 - facing, fresnel_power);

	vec3 facet_axis = normalize(vec3(0.73, 1.0, 0.41));
	float facet_wave = sin(dot(normalize(NORMAL), facet_axis) * facet_scale + object_position.y * 2.0);
	float facet = facet_wave * 0.5 + 0.5;
	vec3 body_color = emerald_color.rgb * mix(1.0 - facet_contrast, 1.0 + facet_contrast, facet);

	float depth_tint = mix(1.0 - absorption * 0.22, 1.0, facing);
	ALBEDO = mix(body_color * depth_tint, edge_color.rgb, fresnel * 0.55);
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;

	float sparkle_pattern = sin(
		dot(object_position, vec3(9.7, 13.1, 7.3)) +
		TIME * sparkle_speed * 6.28318
	);
	float sparkle = pow(max(sparkle_pattern, 0.0), 18.0) * sparkle_strength;
	EMISSION = edge_color.rgb * (fresnel * edge_intensity + sparkle + internal_glow * (1.0 - facing));
	ALPHA = clamp(opacity + fresnel * (1.0 - opacity), 0.0, 1.0);
}
