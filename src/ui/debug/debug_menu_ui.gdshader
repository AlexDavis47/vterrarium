shader_type canvas_item;

// Shadow properties
uniform vec2 shadow_offset = vec2(4.0, 4.0);
uniform float shadow_radius: hint_range(0.0, 10.0) = 3.0;
uniform vec4 shadow_color: source_color = vec4(0.0, 0.0, 0.0, 0.5);

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
    
    // Apply blur to the shadow by sampling in a radius
    for (float x = -shadow_radius; x <= shadow_radius; x += 1.0) {
        for (float y = -shadow_radius; y <= shadow_radius; y += 1.0) {
            // Calculate distance from center of blur
            float dist = sqrt(x*x + y*y);
            
            // Skip pixels outside our radius
            if (dist <= shadow_radius) {
                // Sample with linear falloff based on distance
                float weight = 1.0 - (dist / shadow_radius);
                shadow_alpha += texture(TEXTURE, shadow_uv + vec2(x, y) * ps).a * weight;
            }
        }
    }
    
    // Normalize the shadow alpha
    shadow_alpha = min(shadow_alpha / (shadow_radius * 2.0), 1.0);
    
    // Create the shadow with the sampled alpha
    vec4 shadow = shadow_color;
    shadow.a *= shadow_alpha;
    
    // Add the shadow to our output
    COLOR = shadow;
    
    // Then add the original content on top (normal blend mode)
    COLOR.rgb = mix(COLOR.rgb, current_color.rgb, current_color.a);
    COLOR.a = max(COLOR.a, current_color.a);
}