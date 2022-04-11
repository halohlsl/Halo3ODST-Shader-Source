
#define DETAIL_MULTIPLIER 4.59479f
// 4.59479f == 2 ^ 2.2  (sRGB gamma)

PARAM(float4, albedo_color);
PARAM(float4, albedo_color2);		// used for color-mask
PARAM(float4, albedo_color3);

PARAM_SAMPLER_2D(base_map);
PARAM(float4, base_map_xform);
PARAM_SAMPLER_2D(detail_map);
PARAM(float4, detail_map_xform);

#if defined(pc) && (DX_VERSION == 9)
PARAM(float4, debug_tint);
#endif // pc

float3 calc_pc_albedo_lighting(
	in float3 albedo,
	in float3 normal)
{
	float3 light_direction1= float3(0.68f, 0.48f, -0.6f);
	float3 light_direction2= float3(-0.3f, -0.7f, -0.6f);
	
	float3 light_color1= float3(1.2f, 1.2f, 1.2f);
	float3 light_color2= float3(0.5f, 0.5f, 0.5f);
	float3 light_color3= float3(0.7f, 0.7f, 0.7f);
	float3 light_color4= float3(0.4f, 0.4f, 0.4f);
	
	float3 n_dot_l;
	
	n_dot_l= saturate(dot(normal, light_direction1))*light_color1;
	n_dot_l+= saturate(dot(normal, -light_direction1))*light_color2;
	n_dot_l+= saturate(dot(normal, light_direction2))*light_color3;
	n_dot_l+= saturate(dot(normal, -light_direction2))*light_color4;

	return(n_dot_l*albedo);
}

float3 srgb_de_gamma (float3 Csrgb)
{
   return (Csrgb<=0.04045f) ? (Csrgb/12.92f) : pow((Csrgb + 0.055f)/1.055f, 2.4f);
}
float3 srgb_gamma  (float3 Clinear)
{
   return (Clinear<=.0031308f) ? (12.92f * Clinear) : (1.055f * pow(Clinear,1.f/2.4f)) - 0.055f;
}


void apply_pc_albedo_modifier(
	inout float4 albedo,
	in float3 normal)
{
#if defined(pc) && (DX_VERSION == 9)
	albedo.rgb= lerp(albedo.rgb, debug_tint.rgb, debug_tint.a);
	
	if (p_shader_pc_albedo_lighting!=0.f)
	{
		albedo.xyz= calc_pc_albedo_lighting(albedo.xyz, normal);
	}
	// apply gamma correction by hand on PC to color target only
//	albedo.rgb= srgb_gamma(albedo.rgb);
#endif // pc
}

void calc_albedo_constant_color_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	albedo= albedo_color;
	
	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_default_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4	base=	sample2D(base_map,   transform_texcoord(texcoord, base_map_xform));
	float4	detail=	sample2D(detail_map, transform_texcoord(texcoord, detail_map_xform));

	albedo.rgb= base.rgb * (detail.rgb * DETAIL_MULTIPLIER) * albedo_color.rgb;
	albedo.w= base.w*detail.w*albedo_color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(detail_map2);
PARAM(float4, detail_map2_xform);

void calc_albedo_detail_blend_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4	base=	sample2D(base_map,		transform_texcoord(texcoord, base_map_xform));
	float4	detail=	sample2D(detail_map,	transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2= sample2D(detail_map2,	transform_texcoord(texcoord, detail_map2_xform));

	albedo.xyz= (1.0f-base.w)*detail.xyz + base.w*detail2.xyz;
	albedo.xyz= DETAIL_MULTIPLIER * base.xyz*albedo.xyz;
	albedo.w= (1.0f-base.w)*detail.w + base.w*detail2.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(detail_map3);
PARAM(float4, detail_map3_xform);

void calc_albedo_three_detail_blend_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4 base=	sample2D(base_map,		transform_texcoord(texcoord, base_map_xform));
	float4 detail1= sample2D(detail_map,	transform_texcoord(texcoord, detail_map_xform));
	float4 detail2= sample2D(detail_map2,	transform_texcoord(texcoord, detail_map2_xform));
	float4 detail3= sample2D(detail_map3,	transform_texcoord(texcoord, detail_map3_xform));

	float blend1= saturate(2.0f*base.w);
	float blend2= saturate(2.0f*base.w - 1.0f);

	float4 first_blend=  (1.0f-blend1)*detail1		+ blend1*detail2;
	float4 second_blend= (1.0f-blend2)*first_blend	+ blend2*detail3;

	albedo.rgb= DETAIL_MULTIPLIER * base.rgb * second_blend.rgb;
	albedo.a= second_blend.a;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(change_color_map);
PARAM(float4, change_color_map_xform);
PARAM(float3, primary_change_color);
PARAM(float3, secondary_change_color);
PARAM(float3, tertiary_change_color);
PARAM(float3, quaternary_change_color);

void calc_albedo_two_change_color_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4 base=			sample2D(base_map,			transform_texcoord(texcoord, base_map_xform));
	float4 detail=			sample2D(detail_map,		transform_texcoord(texcoord, detail_map_xform));
	float4 change_color=	sample2D(change_color_map, 	transform_texcoord(texcoord, change_color_map_xform));

	change_color.xyz=	((1.0f-change_color.x) + change_color.x*primary_change_color.xyz)*
						((1.0f-change_color.y) + change_color.y*secondary_change_color.xyz);

	albedo.xyz= DETAIL_MULTIPLIER * base.xyz*detail.xyz*change_color.xyz;
	albedo.w= base.w*detail.w;
	
	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_four_change_color_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4 base=			sample2D(base_map,			transform_texcoord(texcoord, base_map_xform));
	float4 detail=			sample2D(detail_map,		transform_texcoord(texcoord, detail_map_xform));
	float4 change_color=	sample2D(change_color_map,	transform_texcoord(texcoord, change_color_map_xform));

	change_color.xyz=	((1.0f-change_color.x) + change_color.x*primary_change_color.xyz)	*
						((1.0f-change_color.y) + change_color.y*secondary_change_color.xyz)	*
						((1.0f-change_color.z) + change_color.z*tertiary_change_color.xyz)	*
						((1.0f-change_color.w) + change_color.w*quaternary_change_color.xyz);

	albedo.xyz= DETAIL_MULTIPLIER * base.xyz*detail.xyz*change_color.xyz;
	albedo.w= base.w*detail.w;
	
	apply_pc_albedo_modifier(albedo, normal);
}


PARAM_SAMPLER_2D(detail_map_overlay);
PARAM(float4, detail_map_overlay_xform);

void calc_albedo_two_detail_overlay_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4	base=				sample2D(base_map,				transform_texcoord(texcoord, base_map_xform));
	float4	detail=				sample2D(detail_map,			transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2=			sample2D(detail_map2,			transform_texcoord(texcoord, detail_map2_xform));
	float4	detail_overlay=		sample2D(detail_map_overlay,	transform_texcoord(texcoord, detail_map_overlay_xform));

	float4 detail_blend= (1.0f-base.w)*detail + base.w*detail2;
	
	albedo.xyz= base.xyz * (DETAIL_MULTIPLIER * DETAIL_MULTIPLIER) * detail_blend.xyz * detail_overlay.xyz;
	albedo.w= detail_blend.w * detail_overlay.w;

	apply_pc_albedo_modifier(albedo, normal);
}


void calc_albedo_two_detail_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4	base=				sample2D(base_map,				transform_texcoord(texcoord, base_map_xform));
	float4	detail=				sample2D(detail_map,			transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2=			sample2D(detail_map2,			transform_texcoord(texcoord, detail_map2_xform));
	
	albedo.xyz= base.xyz * (DETAIL_MULTIPLIER * DETAIL_MULTIPLIER) * detail.xyz * detail2.xyz;
	albedo.w= base.w * detail.w * detail2.w;

	apply_pc_albedo_modifier(albedo, normal);
}


PARAM_SAMPLER_2D(color_mask_map);
PARAM(float4, color_mask_map_xform);
PARAM(float4, neutral_gray);

void calc_albedo_color_mask_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4	base=	sample2D(base_map,   transform_texcoord(texcoord, base_map_xform));
	float4	detail=	sample2D(detail_map, transform_texcoord(texcoord, detail_map_xform));
	float4  color_mask=	sample2D(color_mask_map,	transform_texcoord(texcoord, color_mask_map_xform));

	float4 tint_color=	((1.0f-color_mask.x) + color_mask.x * albedo_color.xyzw / float4(neutral_gray.xyz, 1.0f))		*		// ###ctchou $PERF do this divide in the pre-process
						((1.0f-color_mask.y) + color_mask.y * albedo_color2.xyzw / float4(neutral_gray.xyz, 1.0f))		*
						((1.0f-color_mask.z) + color_mask.z * albedo_color3.xyzw / float4(neutral_gray.xyz, 1.0f));

	albedo.rgb= base.rgb * (detail.rgb * DETAIL_MULTIPLIER) * tint_color.rgb;
	albedo.w= base.w * detail.w * tint_color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_two_detail_black_point_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal)
{
	float4	base=				sample2D(base_map,				transform_texcoord(texcoord, base_map_xform));
	float4	detail=				sample2D(detail_map,			transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2=			sample2D(detail_map2,			transform_texcoord(texcoord, detail_map2_xform));
	
	albedo.xyz= base.xyz * (DETAIL_MULTIPLIER * DETAIL_MULTIPLIER) * detail.xyz * detail2.xyz;
	albedo.w= apply_black_point(base.w, detail.w * detail2.w);

	apply_pc_albedo_modifier(albedo, normal);
}
