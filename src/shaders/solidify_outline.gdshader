shader_type spatial;
render_mode cull_disabled;

uniform float outline_width = 0.02;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void vertex() {
    // Offset vertices along their normals
    VERTEX += NORMAL * outline_width;
}

void fragment() {
    // For the back faces, use the outline color
    if (!FRONT_FACING) {
        ALBEDO = outline_color.rgb;
        // Make sure the outline is fully opaque
        ALPHA = outline_color.a;
    } else {
        // Discard the original front faces for this pass
        discard;
    }
}