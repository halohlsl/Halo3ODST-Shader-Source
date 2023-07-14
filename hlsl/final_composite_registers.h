#ifndef _FINAL_COMPOSITE_REGISTERS_H_
#define _FINAL_COMPOSITE_REGISTERS_H_

#if DX_VERSION == 9

#include "postprocess_registers.h"

#define k_ps_final_composite_intensity					POSTPROCESS_DEFAULT_PIXEL_CONSTANT
#define k_ps_final_composite_tone_curve_constants		POSTPROCESS_EXTRA_PIXEL_CONSTANT_0
#define k_ps_final_composite_player_window_constants	POSTPROCESS_EXTRA_PIXEL_CONSTANT_1
#define k_ps_final_composite_screenspace_sampler_xform	POSTPROCESS_EXTRA_PIXEL_CONSTANT_2

#define k_ps_final_composite_depth_constants			POSTPROCESS_EXTRA_PIXEL_CONSTANT_3
#define k_ps_final_composite_depth_constants2			POSTPROCESS_EXTRA_PIXEL_CONSTANT_4

#define k_ps_final_composite_health_constants 8
#define k_ps_final_composite_health_mult_base 9
#define k_ps_final_composite_health_mult_scale 10
#define k_ps_final_composite_health_add_base 11
#define k_ps_final_composite_health_add_scale 12

#define k_ps_final_composite_shield_constants 13
#define k_ps_final_composite_shield_mult_base 14
#define k_ps_final_composite_shield_mult_scale 15
#define k_ps_final_composite_shield_add_base 16
#define k_ps_final_composite_shield_add_scale 17

#elif DX_VERSION == 11

#define FX_FILE "rasterizer\\hlsl\\final_composite_registers.fx"
#include "rasterizer\dx11\rasterizer_dx11_define_fx_constants.h"
#undef FX_FILE

#endif

#endif