//#line 2 "source\rasterizer\hlsl\shield_impact.hlsl"

#include "global.fx"
#include "hlsl_constant_mapping.fx"

#include "deform.fx"
#include "stipple.fx"

#define LDR_ALPHA_ADJUST g_exposure.w
#define HDR_ALPHA_ADJUST g_exposure.b
#define DARK_COLOR_MULTIPLIER g_exposure.g
#include "render_target.fx"
#include "shield_impact_registers.fx"

// noise textures
LOCAL_SAMPLER_2D(shield_impact_noise_texture1, 0);
LOCAL_SAMPLER_2D(shield_impact_noise_texture2, 1);


// Magic line to compile this for various needed vertex types
//@generate rigid
//@generate world
//@generate skinned

struct s_vertex_out
{
	float4 position : SV_Position;
	float4 world_space_pos : TEXCOORD1;
	float4 texcoord : TEXCOORD2;
};

s_vertex_out default_vs(
	in vertex_type vertex_in
	)
{
	s_vertex_out vertex_out;

	float4 local_to_world_transform[3];
	
	deform(vertex_in, local_to_world_transform);
	 	
	vertex_in.position+= vertex_in.normal * extrusion_distance;
	
	float cosine_view=	dot(normalize(Camera_Position.xyz - vertex_in.position.xyz), vertex_in.normal);
	vertex_out.world_space_pos= float4(vertex_in.position, cosine_view);	
	vertex_out.position= mul(float4(vertex_in.position, 1.0f), View_Projection);	
	vertex_out.texcoord.xyzw= vertex_in.texcoord.xyxx;
	
	return vertex_out;
}

// things to expose:
// VS
// extrusion amount
// PS
// texture 1 & 2 scroll rate
// shield color, shield hot color
// intensity exponent, bias, and scale

accum_pixel default_ps(s_vertex_out pixel_in)
{
	float3 xyz_relative= float3(pixel_in.world_space_pos.xyz - bound_sphere.xyz);
	
	float noise_value1, noise_value2;
	
	float time_parameter= texture_quantities.y * shield_dynamic_quantities.x;
	noise_value1= sample2D(shield_impact_noise_texture1, (pixel_in.texcoord.xy + float2(time_parameter / 12.0f, time_parameter / 13.0f)) * texture_quantities.x);
	noise_value2= sample2D(shield_impact_noise_texture2, (pixel_in.texcoord.xy - float2(time_parameter / 11.0f, time_parameter / 17.0f)) * texture_quantities.x);
	
	float plasma_base= 1.0f-abs(noise_value1 - noise_value2);
	float plasma_value1= max(0, (pow(plasma_base, plasma1_settings.x)-plasma1_settings.z) * plasma1_settings.y);
	float plasma_value2= max(0, (pow(plasma_base, plasma2_settings.x)-plasma2_settings.z) * plasma2_settings.y);

	float non_plasma_value= 1.0f - min(1.0f, (plasma_value1 + plasma_value2));
	float shield_impact_factor= shield_dynamic_quantities.y;
	float overshield_factor= shield_dynamic_quantities.z;
	
	float3 semifinal_shield_impact_color= shield_impact_factor * (plasma_value1 * shield_impact_color1 + plasma_value2 * shield_impact_color2 + non_plasma_value * shield_impact_ambient_color);
	float3 semifinal_overshield_color= overshield_factor * (plasma_value1 * overshield_color1 + plasma_value2 * overshield_color2 + non_plasma_value * overshield_ambient_color);
	
	float4 final_color= float4(semifinal_shield_impact_color + semifinal_overshield_color, 1.0f) * pow(saturate(pixel_in.world_space_pos.w), shield_impact_edge_fade) * g_exposure.r;
	return convert_to_render_target(final_color, false, false);
}

#if DX_VERSION == 11
//@entry stipple

void stipple_vs(
	in vertex_type vertex,
	out float4 position : SV_Position)
{
	float4 local_to_world_transform[3];
	
	deform(vertex, local_to_world_transform);
	 
	vertex.position+= vertex.normal * extrusion_distance;
	
	position = mul(float4(vertex.position, 1.0f), View_Projection);
}

float4 stipple_ps(SCREEN_POSITION_INPUT(screen_position)) : SV_Target
{
	stipple_test(screen_position);
	return 0;
}
#endif
