#ifndef _FINAL_COMPOSITE_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _FINAL_COMPOSITE_REGISTERS_FX_
#endif

#if DX_VERSION == 9

#include "final_composite_registers.h"

PIXEL_CONSTANT(float4, intensity,					k_ps_final_composite_intensity);				// unused:			natural, bloom, bling, persist
PIXEL_CONSTANT(float4, tone_curve_constants,		k_ps_final_composite_tone_curve_constants);		// tone curve:		max, linear, quadratic, cubic terms
PIXEL_CONSTANT(float4, player_window_constants, 	k_ps_final_composite_player_window_constants);	// weapon zoom:		x, y, (left top corner), z,w (width, height);
PIXEL_CONSTANT(float4, screenspace_sampler_xform,	k_ps_final_composite_screenspace_sampler_xform);		// 
PIXEL_CONSTANT(float4, depth_constants,				POSTPROCESS_EXTRA_PIXEL_CONSTANT_3);			// depth of field:	1/near,  -(far-near)/(far*near), focus distance, aperture
PIXEL_CONSTANT(float4, depth_constants2,			POSTPROCESS_EXTRA_PIXEL_CONSTANT_4);			// depth of field:	focus half width

PIXEL_CONSTANT(float4, health_constants,			k_ps_final_composite_health_constants);			// health percentage
PIXEL_CONSTANT(float4, health_mult_base,			k_ps_final_composite_health_mult_base);			// health mult color
PIXEL_CONSTANT(float4, health_mult_scale,			k_ps_final_composite_health_mult_scale);		//
PIXEL_CONSTANT(float4, health_add_base,				k_ps_final_composite_health_add_base);			// health mult color
PIXEL_CONSTANT(float4, health_add_scale,			k_ps_final_composite_health_add_scale);			//

PIXEL_CONSTANT(float4, shield_constants,			k_ps_final_composite_shield_constants);			// health percentage
PIXEL_CONSTANT(float4, shield_mult_base,			k_ps_final_composite_shield_mult_base);			// health mult color
PIXEL_CONSTANT(float4, shield_mult_scale,			k_ps_final_composite_shield_mult_scale);		//
PIXEL_CONSTANT(float4, shield_add_base,				k_ps_final_composite_shield_add_base);			// health mult color
PIXEL_CONSTANT(float4, shield_add_scale,			k_ps_final_composite_shield_add_scale);			//

#elif DX_VERSION == 11

CBUFFER_BEGIN(FinalCompositePS)
	CBUFFER_CONST(FinalCompositePS,		float4, 	intensity,					k_ps_final_composite_intensity)
	CBUFFER_CONST(FinalCompositePS,		float4, 	tone_curve_constants,		k_ps_final_composite_tone_curve_constants)
	CBUFFER_CONST(FinalCompositePS,		float4, 	player_window_constants, 	k_ps_final_composite_player_window_constants)
	CBUFFER_CONST(FinalCompositePS,		float4, 	screenspace_sampler_xform,	k_ps_final_composite_screenspace_sampler_xform)
	CBUFFER_CONST(FinalCompositePS,		float4,		health_constants,			k_ps_final_composite_health_constants)
	CBUFFER_CONST(FinalCompositePS,		float4,		health_mult_base,			k_ps_final_composite_health_mult_base)
	CBUFFER_CONST(FinalCompositePS,		float4,		health_mult_scale,			k_ps_final_composite_health_mult_scale)
	CBUFFER_CONST(FinalCompositePS,		float4,		health_add_base,			k_ps_final_composite_health_add_base)
	CBUFFER_CONST(FinalCompositePS,		float4,		health_add_scale,			k_ps_final_composite_health_add_scale)
	CBUFFER_CONST(FinalCompositePS,		float4,		shield_constants,			k_ps_final_composite_shield_constants)
	CBUFFER_CONST(FinalCompositePS,		float4,		shield_mult_base,			k_ps_final_composite_shield_mult_base)
	CBUFFER_CONST(FinalCompositePS,		float4,		shield_mult_scale,			k_ps_final_composite_shield_mult_scale)
	CBUFFER_CONST(FinalCompositePS,		float4,		shield_add_base,			k_ps_final_composite_shield_add_base)
	CBUFFER_CONST(FinalCompositePS,		float4,		shield_add_scale,			k_ps_final_composite_shield_add_scale)
CBUFFER_END

CBUFFER_BEGIN(FinalCompositeDOFPS)
	CBUFFER_CONST(FinalCompositeDOFPS,	float4,		depth_constants,			k_ps_final_composite_depth_constants)
	CBUFFER_CONST(FinalCompositeDOFPS,	float4,		depth_constants2,			k_ps_final_composite_depth_constants2)
CBUFFER_END


#endif

#endif
