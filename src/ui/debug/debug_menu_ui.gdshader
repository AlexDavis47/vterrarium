shader_type canvas_item;

// Shadow properties
uniform vec2 shadow_offset = vec2(8.0, 8.0);
uniform float shadow_radius: hint_range(0.0, 20.0) = 5.0;
uniform float shadow_blur: hint_range(0.0, 5.0) = 2.0;
uniform vec4 shadow_color: source_color = vec4(0.0, 0.0, 0.0, 0.5);

// Gaussian function for more natural blur
float gaussian(float x, float sigma) {
	return exp(-(x*x) / (2.0 * sigma * sigma)) / (sqrt(2.0 * 3.14159) * sigma);
}

void fragment() {
	// Get the current pixel color
	vec4 current_color = texture(TEXTURE, UV);
	
	// Start with a fully transparent output color
	COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	
	// First, add the shadow by sampling the texture at an offset position
	vec2 ps = TEXTURE_PIXEL_SIZE;
	
	// Calculate the shadow UV coordinate
	vec2 shadow_uv = UV - shadow_offset * ps;
	
	// Sample the original texture's alpha channel at the shadow position
	float shadow_alpha = 0.0;
	float total_weight = 0.0;
	
	// Apply Gaussian blur to the shadow by sampling in a radius
	float sigma = shadow_blur + 0.5; // Adjust sigma based on blur strength
	
	for (float x = -shadow_radius; x <= shadow_radius; x += 1.0) {
		for (float y = -shadow_radius; y <= shadow_radius; y += 1.0) {
			// Calculate distance from center of blur
			float dist = sqrt(x*x + y*y);
			
			// Skip pixels outside our radius
			if (dist <= shadow_radius) {
				// Sample with Gaussian weight for better quality blur
				float weight = gaussian(dist / shadow_radius, sigma);
				vec2 sample_pos = shadow_uv + vec2(x, y) * ps;
				
				// Only sample within texture bounds
				if (sample_pos.x >= 0.0 && sample_pos.x <= 1.0 && 
					sample_pos.y >= 0.0 && sample_pos.y <= 1.0) {
					shadow_alpha += texture(TEXTURE, sample_pos).a * weight;
					total_weight += weight;
				}
			}
		}
	}
	
	// Normalize the shadow alpha
	if (total_weight > 0.0) {
		shadow_alpha /= total_weight;
	}
	
	// Create the shadow with the sampled alpha
	vec4 shadow = shadow_color;
	shadow.a *= shadow_alpha;
	
	// Add the shadow to our output
	COLOR = shadow;
	
	// Then add the original content on top (normal blend mode)
	COLOR.rgb = mix(COLOR.rgb, current_color.rgb, current_color.a);
	COLOR.a = max(COLOR.a, current_color.a);
}