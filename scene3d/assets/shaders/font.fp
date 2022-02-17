#extension GL_OES_standard_derivatives : enable

varying highp vec2 var_texcoord0;
varying lowp vec4 var_face_color;
varying lowp vec4 var_outline_color;
varying lowp vec4 var_shadow_color;
varying lowp vec4 var_layer_mask;

uniform mediump sampler2D texture_sampler;

// Rotated grid UV offsets
const mediump vec2 rgss_uv_offsets = vec2(0.125, 0.375);

mediump vec4 rgss_tex2D(mediump sampler2D tex, highp vec2 uv)
{
    // Per pixel partial derivatives
    mediump vec2 dx = dFdx(uv);
    mediump vec2 dy = dFdy(uv);

    // Supersampled using 2x2 rotated grid
    mediump vec4 col = texture2D(tex, vec2(uv + rgss_uv_offsets.x * dx + rgss_uv_offsets.y * dy));
    col += texture2D(tex, vec2(uv - rgss_uv_offsets.x * dx - rgss_uv_offsets.y * dy));
    col += texture2D(tex, vec2(uv + rgss_uv_offsets.y * dx - rgss_uv_offsets.x * dy));
    col += texture2D(tex, vec2(uv - rgss_uv_offsets.y * dx + rgss_uv_offsets.x * dy));

    col *= 0.25;

    return col;
}

void main()
{
    lowp float is_single_layer = var_layer_mask.a;
    lowp vec3 t                = rgss_tex2D(texture_sampler, var_texcoord0.xy).xyz;
    lowp float face_alpha      = t.x * var_face_color.w;
    gl_FragColor      = (var_layer_mask.x * face_alpha * vec4(var_face_color.xyz, 1.0) +
        var_layer_mask.y * vec4(var_outline_color.xyz, 1.0) * var_outline_color.w * t.y * (1.0 - face_alpha * is_single_layer) +
        var_layer_mask.z * vec4(var_shadow_color.xyz, 1.0) * var_shadow_color.w * t.z * (1.0 - min(1.0, t.x + t.y) * is_single_layer));
}
