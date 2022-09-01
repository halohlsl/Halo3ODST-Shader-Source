#line 2 "source\rasterizer\hlsl\final_composite_base.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "postprocess.fx"
#include "utilities.fx"
#include "texture_xform.fx"
#include "final_composite_registers.fx"


LOCAL_SAMPLER_2D(surface_sampler, 0);		
LOCAL_SAMPLER_2D(dark_surface_sampler, 1);		
LOCAL_SAMPLER_2D(bloom_sampler, 2);		
LOCAL_SAMPLER_2D(depth_sampler, 3);		// depth of field
LOCAL_SAMPLER_2D(blur_sampler, 4);		// depth of field
LOCAL_SAMPLER_2D(blur_grade_sampler, 5);		// weapon zoom
//LOCAL_SAMPLER_2D(health_sampler, 6);		// health effect
LOCAL_SAMPLER_2D(shield_sampler, 7);		// health effect




// define default functions, if they haven't been already

#ifndef COMBINE_HDR_LDR
#define COMBINE_HDR_LDR default_combine_optimized
#endif // !COMBINE_HDR_LDR

#ifndef CALC_BLOOM
#define CALC_BLOOM default_calc_bloom
#endif // !CALC_BLOOM

#ifndef CALC_BLEND
#define CALC_BLEND default_calc_blend
#endif // !CALC_BLEND


#ifndef CALC_HEALTH_OVERLAY
#define CALC_HEALTH_OVERLAY default_calc_health_overlay
#endif // !CALC_HEALTH_OVERLAY

#ifndef CALC_SHIELD_OVERLAY
#define CALC_SHIELD_OVERLAY default_calc_shield_overlay
#endif // !CALC_SHIELD_OVERLAY

#ifndef SCREENSPACE_TRANSFORM_COORDS
#define SCREENSPACE_TRANSFORM_COORDS(t) t 
#endif



float4 default_combine_hdr_ldr(in float2 texcoord)							// supports multiple sources and formats, but much slower than the optimized version
{
#ifdef pc
	float4 accum=		sample2D(surface_sampler, texcoord);
	float4 accum_dark=	sample2D(dark_surface_sampler, texcoord) * DARK_COLOR_MULTIPLIER;
	float4 combined = accum_dark * step(accum_dark, (1).rrrr);
	combined = max(accum, combined);
#else // XENON
	
	float4 accum=		sample2D(surface_sampler, texcoord);
	if (LDR_gamma2)
	{
		accum.rgb *= accum.rgb;
	}

	float4 accum_dark=	sample2D(dark_surface_sampler, texcoord);
	if (HDR_gamma2)
	{
		accum_dark.rgb *= accum_dark.rgb;
	}
	accum_dark *= DARK_COLOR_MULTIPLIER;
	
/*	float4 combined= accum_dark - 1.0f;
	asm																		// combined = ( combined > 0.0f ) ? accum_dark : accum
	{
		cndgt combined, combined, accum_dark, accum
	};
*/
	float4 combined= max(accum, accum_dark);
#endif // XENON

	return combined;
}


float4 default_combine_optimized(in float2 texcoord)						// final game code: single sample LDR surface, use hardcoded hardware curve
{
	return sample2D(surface_sampler, texcoord);
}


float4 default_calc_bloom(in float2 texcoord)
{
	return tex2D_offset(bloom_sampler, texcoord, 0, 0);
}


float3 default_calc_blend(in float2 texcoord, in float4 combined, in float4 bloom)
{
#ifdef pc
	return combined + bloom;
#else // XENON
	return combined * bloom.a + bloom.rgb;
#endif // XENON
}


float3 default_calc_health_overlay(in float2 texcoord, in float3 base_color)
{
/*
	// ###ctchou $NOTE optimization to remove this since it is never used in Halo3:ODST
	float ramp= sample2D(health_sampler, texcoord).a;	
	float health= health_constants.x;

	float total_health= ramp - health;
	float blend= saturate(total_health);	// smoothstep(0.0f, 1.0f, total_health);

	float3 health_mult= health_mult_base + health_mult_scale * blend;
	float3 health_add=  health_add_base + health_add_scale * blend;

	return base_color * health_mult + health_add;
*/
	return base_color;	
}
 
float3 default_calc_shield_overlay(in float2 texcoord, in float3 base_color)
{
	float2 tc = float2(texcoord.x*shield_constants.z + 0.5f-shield_constants.z*0.5f, texcoord.y*shield_constants.w + 0.5f-shield_constants.w*0.5f);

	float ramp= sample2D(shield_sampler, tc).a;	
	float shield= shield_constants.x;

	float total_shield= ramp - shield;
	float blend=	saturate(total_shield);

	float3 shield_mult= shield_mult_base + shield_mult_scale * blend;
	float3 shield_add=  shield_add_base + shield_add_scale * blend;

	return base_color * shield_mult + shield_add;
}
 
float4 default_ps(SCREEN_POSITION_INPUT(screen_position), in float2 texcoord :TEXCOORD0) : SV_Target
{
	float2 screenspace_coords= SCREENSPACE_TRANSFORM_COORDS(texcoord);

	// final composite
	float4 combined= COMBINE_HDR_LDR(texcoord);									// sample and blend full resolution render targets
	float4 bloom= CALC_BLOOM(screenspace_coords);								// sample postprocessed buffer(s)
	float3 blend= CALC_BLEND(texcoord, combined, bloom);						// blend them together

	blend= CALC_SHIELD_OVERLAY(screenspace_coords, blend);
	blend= CALC_HEALTH_OVERLAY(screenspace_coords, blend);

#if (! defined(pc)) || (DX_VERSION == 11)
	// apply hue and saturation (3 instructions)
	blend= mul(float4(blend, 1.0f), p_postprocess_hue_saturation_matrix);

	// apply contrast (4 instructions)
	float luminance= dot(blend, float3(0.333f, 0.333f, 0.333f));
#if DX_VERSION == 11
	if (luminance > 0)
#endif
	{
		blend *= pow(luminance, p_postprocess_contrast.x) / luminance;
	}
#endif // !pc

	// apply tone curve (4 instructions)
	float3 clamped  = min(blend, tone_curve_constants.xxx);		// default= 1.4938015821857215695824940046795		// r1

	float4 result;
	result.rgb= ((clamped.rgb * tone_curve_constants.w + tone_curve_constants.z) * clamped.rgb + tone_curve_constants.y) * clamped.rgb;		// default linear = 1.0041494251232542828239889869599, quadratic= 0, cubic= - 0.15;
	result.a= sqrt(dot(result.rgb, float3(0.299, 0.587, 0.114)));
	
	return result;
}
