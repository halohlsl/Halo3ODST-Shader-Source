#ifndef _HUD_CAMERA_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _HUD_CAMERA_REGISTERS_FX_
#endif

#if DX_VERSION == 9

PIXEL_CONSTANT(float4, colors[5], k_ps_hud_camera_colors)

#include "hud_camera_registers.h"

#elif DX_VERSION == 11

CBUFFER_BEGIN(HUDCameraPS)
	CBUFFER_CONST_ARRAY(HUDCameraPS,	float4,	colors,	[5],	k_ps_hud_camera_colors)
CBUFFER_END

#endif

#endif
