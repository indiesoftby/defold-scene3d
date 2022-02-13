varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_position;
varying mediump vec3 var_normal;
// varying highp vec2 var_texcoord0;
varying lowp vec3 var_color;

uniform lowp vec4 tint;
uniform highp vec4 fog;
uniform lowp vec4 fog_color;
uniform mediump vec4 light_directional;
uniform mediump vec4 light_ambient;

void main()
{
    // Pre-multiply alpha since all Defold materials do that
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);

    // Vertex color
    vec3 color = var_color;

    // Directional light
    float diff_intensity = light_directional.w;
    float diff_light = max(dot(var_world_normal, normalize(light_directional.xyz)), 0.0) * diff_intensity;
    float ambient_intensity = light_ambient.w;
    vec3 light = (ambient_intensity + diff_light) * light_ambient.rgb;
    vec3 final_color = (tint_pm.rgb * color) * light;

    // Fog
    float distance = abs(var_position.z);
    float fog_min = fog.x;
    float fog_max = fog.y;
    float fog_intensity = fog.w;
    float fog_factor = (1.0 - clamp((fog_max - distance) / (fog_max - fog_min), 0.0, 1.0)) * fog_intensity;

    // Gamma correction + Fog
    gl_FragColor = vec4(mix(final_color, fog_color.rgb, fog_factor), 1.0);
}

