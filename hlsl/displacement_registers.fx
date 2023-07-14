/*
DISPLACEMENT_REGISTERS.FX
Copyright (c) Microsoft Corporation, 2007. all rights reserved.
3/21/2007 4:57:42 PM (davcook)
	
*/


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


