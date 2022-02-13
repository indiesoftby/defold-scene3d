varying highp vec3 var_world_position;
varying mediump vec3 var_world_normal;
varying highp vec3 var_position;
varying mediump vec3 var_normal;
varying highp vec2 var_texcoord0;

uniform lowp vec4 tint;
uniform highp vec4 fog;
uniform lowp vec4 fog_color;
uniform mediump vec4 grid;
uniform mediump vec4 light_directional;
uniform mediump vec4 light_ambient;

uniform lowp sampler2D texture0;

lowp vec3 triplanar_sampling(sampler2D tex_x, sampler2D tex_y, sampler2D tex_z, vec3 world_pos, vec3 world_normal, float falloff, vec2 tiling)
{
    vec3 proj_normal = pow(abs(world_normal), vec3(falloff));
    proj_normal /= (proj_normal.x + proj_normal.y + proj_normal.z) + 0.00001;
    vec3 norm_sign = sign(world_normal);
    lowp vec3 x_norm = texture2D(tex_x, tiling * world_pos.zy * vec2(norm_sign.x, 1.0)).rgb;
    lowp vec3 y_norm = texture2D(tex_y, tiling * world_pos.xz * vec2(norm_sign.y, 1.0)).rgb;
    lowp vec3 z_norm = texture2D(tex_z, tiling * world_pos.xy * vec2(-norm_sign.z, 1.0)).rgb;
    return x_norm * proj_normal.x + y_norm * proj_normal.y + z_norm * proj_normal.z;
}

void main()
{
    // Pre-multiply alpha since all Defold materials do that
    vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);

    // Make grid
    vec3 overlay_color = mix(vec3(1.0), triplanar_sampling(texture0, texture0, texture0, var_world_position, var_world_normal, grid.z, grid.xy), grid.w);

    // Directional light
    float diff_intensity = light_directional.w;
    float diff_light = max(dot(var_world_normal, normalize(light_directional.xyz)), 0.0) * diff_intensity;
    float ambient_intensity = light_ambient.w;
    vec3 light = (ambient_intensity + diff_light) * light_ambient.rgb;
    vec3 final_color = (tint_pm.rgb * overlay_color) * light;

    // Fog
    float distance = abs(var_position.z);
    float fog_min = fog.x;
    float fog_max = fog.y;
    float fog_intensity = fog.w;
    float fog_factor = (1.0 - clamp((fog_max - distance) / (fog_max - fog_min), 0.0, 1.0)) * fog_intensity;

    // Color + Fog
    gl_FragColor = vec4(mix(final_color, fog_color.rgb, fog_factor), 1.0);
}

