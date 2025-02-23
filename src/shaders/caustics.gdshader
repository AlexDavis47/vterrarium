shader_type spatial;
render_mode blend_mix;

uniform sampler2D caustics_texture; // Your caustics texture
uniform sampler2D noise_texture; // Add noise texture for distortion
uniform vec2 scroll_speed = vec2(0.1, 0.1); // Control the scrolling speed
uniform vec2 noise_speed = vec2(0.05, 0.05); // Separate speed for noise
uniform float distortion_strength = 0.2; // How much the noise distorts
uniform float intensity : hint_range(0.0, 2.0) = 1.0; // Control the brightness
uniform vec4 caustics_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float caustics_scale = 1.0; // Scale of the caustics texture
uniform float noise_scale = 1.0; // Scale of the noise texture

void fragment() {
    // Scale the base UV coordinates
    vec2 scaled_uv = UV * caustics_scale;
    vec2 noise_uv = UV * noise_scale;
    
    // Get UV coordinates for noise with scaling
    noise_uv += noise_speed * TIME;
    
    // Sample noise texture and convert to offset
    vec2 noise_offset = (texture(noise_texture, noise_uv).rg * 2.0 - 1.0) * distortion_strength;
    
    // Get distorted UV coordinates for caustics
    vec2 caustics_uv = scaled_uv + scroll_speed * TIME + noise_offset;
    
    // Sample the caustics texture with distorted UVs
    vec4 caustics = texture(caustics_texture, caustics_uv);
    
    // Apply the caustics effect with alpha for better blending
    ALBEDO = vec3(0.0); // Set base color to black
    ALPHA = caustics.r * intensity * 0.5; // Use alpha for blending, reduced intensity
    EMISSION = caustics.rgb * intensity * caustics_color.rgb * 0.5; // Reduced emission intensity
}