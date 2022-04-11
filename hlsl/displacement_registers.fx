/*
DISPLACEMENT_REGISTERS.FX
Copyright (c) Microsoft Corporation, 2007. all rights reserved.
3/21/2007 4:57:42 PM (davcook)
	
*/

#if DX_VERSION == 9

#include "displacement_registers.h"

// screen_constants.xy == 1/pixel resolution
// screen_constants.zw == screenshot_scale
PIXEL_CONSTANT(float4, screen_constants, k_ps_displacement_screen_constants)

// resolution_constants.xy == pixel resolution (width, height)
// resolution_constants.zw == 1.0 / pixel resolution
VERTEX_CONSTANT(float4, vs_resolution_constants, k_vs_displacement_resolution_constants)

// distort_constants.xy == (screenshot scale) * 2 * max_displacement * (0.5f if multisampled) * resolution.xy		<----------------- convert to pixels
// distort_constants.zw == -distortion_offset * distort_constants.xy
PIXEL_CONSTANT(float4, distort_constants, k_ps_displacement_distort_constants)

PIXEL_CONSTANT(float4, window_bounds, k_ps_displacement_window_bounds)

PIXEL_CONSTANT(float4x4, combined3, k_ps_displacement_combined3)

// .x = total scale
// .y = max blur / total scale
// .z = inverse_num_taps * total scale
// .w = inverse_num_taps * 2 * total scale
PIXEL_CONSTANT(float4, pixel_blur_constants, k_ps_displacement_pixel_blur_constants)

// .xy == misc.w
// .zw == (-center_pixel) * misc.w
PIXEL_CONSTANT(float4, crosshair_constants, k_ps_displacement_crosshair_constants)

BOOL_CONSTANT(do_distortion, k_ps_displacement_do_distortion)

#else

CBUFFER_BEGIN(DisplacementVS)
	CBUFFER_CONST(DisplacementVS,			float4,		vs_resolution_constants,	k_vs_displacement_resolution_constants)
CBUFFER_END

CBUFFER_BEGIN(DisplacementPS)
	CBUFFER_CONST(DisplacementPS,			float4,		screen_constants,			k_ps_displacement_screen_constants)
	CBUFFER_CONST(DisplacementPS,			float4, 	window_bounds, 				k_ps_displacement_window_bounds)
	CBUFFER_CONST(DisplacementPS,			float4, 	distort_constants,			k_ps_displacement_distort_constants)
	CBUFFER_CONST(DisplacementPS,			float4x4,	combined3,					k_ps_displacement_combined3)
CBUFFER_END

CBUFFER_BEGIN(DisplacementMotionBlurPS)
	CBUFFER_CONST(DisplacementMotionBlurPS,	float4, 	pixel_blur_constants, 		k_ps_displacement_pixel_blur_constants)
	CBUFFER_CONST(DisplacementMotionBlurPS,	float4, 	crosshair_constants, 		k_ps_displacement_crosshair_constants)
	CBUFFER_CONST(DisplacementMotionBlurPS,	bool,		do_distortion,				k_ps_displacement_do_distortion)
CBUFFER_END

#endif
