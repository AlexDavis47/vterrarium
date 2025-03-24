// NOTE: Shader automatically converted from Godot Engine 4.4.stable.mono's StandardMaterial3D.
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx, depth_prepass_alpha;

// Original uniforms
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_disable;
uniform ivec2 albedo_texture_size;
uniform float point_size : hint_range(0.1, 128.0, 0.1);
uniform float roughness : hint_range(0.0, 1.0);
uniform sampler2D texture_metallic : hint_default_white, filter_linear_mipmap, repeat_disable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r, filter_linear_mipmap, repeat_disable;
uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

// Added wind uniforms
uniform sampler2D noise_texture : hint_default_white;
uniform float wind_strength : hint_range(0.0, 2.0) = 0.3;
uniform float wind_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wind_scale : hint_range(0.1, 10.0) = 1.0;
uniform vec2 wind_direction = vec2(1.0, 0.3);

void vertex() {
    // Original UV transformation
    UV = UV * uv1_scale.xy + uv1_offset.xy;
    
    // Wind effect
    // Normalize wind direction
    vec2 normalized_wind_dir = normalize(wind_direction);
    
    // Create scrolling effect based on TIME
    vec2 noise_uv = (VERTEX.xz * wind_scale) + (normalized_wind_dir * TIME * wind_speed);
    
    // Sample noise texture
    float noise = texture(noise_texture, noise_uv).r * 2.0 - 1.0;
    
    // Apply wind effect with vertex height as factor (stronger at the top)
    // This makes it more realistic as plants bend more at the top
    float height_factor = smoothstep(0.0, 1.0, VERTEX.y);
    
    // Apply noise to vertex position
    VERTEX.x += noise * wind_strength * height_factor * normalized_wind_dir.x;
    VERTEX.z += noise * wind_strength * height_factor * normalized_wind_dir.y;
    
    // Small vertical movement for more natural effect
    VERTEX.y += noise * wind_strength * 0.1 * height_factor;
}

void fragment() {
    vec2 base_uv = UV;
    vec4 albedo_tex = texture(texture_albedo, base_uv);
    ALBEDO = albedo.rgb * albedo_tex.rgb;
    float metallic_tex = dot(texture(texture_metallic, base_uv), metallic_texture_channel);
    METALLIC = metallic_tex * metallic;
    SPECULAR = specular;
    vec4 roughness_texture_channel = vec4(1.0, 0.0, 0.0, 0.0);
    float roughness_tex = dot(texture(texture_roughness, base_uv), roughness_texture_channel);
    ROUGHNESS = roughness_tex * roughness;
    ALPHA *= albedo.a * albedo_tex.a;
}