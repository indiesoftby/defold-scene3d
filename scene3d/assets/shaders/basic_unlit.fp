varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_position;
varying mediump vec3 var_normal;
varying highp vec2 var_texcoord0;

uniform mediump vec4 tint;

uniform lowp sampler2D texture0;

void main()
{
    vec4 tex_pm = texture2D(texture0, var_texcoord0.xy);

    // Pre-multiply alpha since all Defold materials do that
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);

    vec3 unlit_color = tex_pm.rgb * tint_pm.rgb;

    gl_FragColor = vec4(unlit_color, 1.0);
}
