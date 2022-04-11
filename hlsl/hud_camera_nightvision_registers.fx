#ifndef _HUD_CAMERA_NIGHTVISION_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _HUD_CAMERA_NIGHTVISION_REGISTERS_FX_
#endif

#if DX_VERSION == 9

PIXEL_CONSTANT(float4, falloff, k_ps_hud_camera_nightvision_falloff)
PIXEL_CONSTANT(float4x4, screen_to_world, k_ps_hud_camera_nightvision_screen_to_world)
PIXEL_CONSTANT(float4, ping, k_ps_hud_camera_nightvision_ping)
PIXEL_CONSTANT(float4, colors[5][2], k_ps_hud_camera_nightvision_colors)
PIXEL_CONSTANT(float4, screenspace_xform, k_ps_hud_camera_nightvision_screenspace_xform)

#include "hud_camera_nightvision_registers.h"

#elif DX_VERSION == 11

CBUFFER_BEGIN(HUDCameraNightvisionPS)
	CBUFFER_CONST(HUDCameraNightvisionPS,		float4,		falloff,							k_ps_hud_camera_nightvision_falloff)
	CBUFFER_CONST(HUDCameraNightvisionPS,		float4x4,	screen_to_world,					k_ps_hud_camera_nightvision_screen_to_world)
	CBUFFER_CONST(HUDCameraNightvisionPS,		float4,		ping,								k_ps_hud_camera_nightvision_ping)
	CBUFFER_CONST_ARRAY(HUDCameraNightvisionPS,	float4,		colors,	[5][2],						k_ps_hud_camera_nightvision_colors)
	CBUFFER_CONST(HUDCameraNightvisionPS,		float4,		screenspace_xform,					k_ps_hud_camera_nightvision_screenspace_xform)
CBUFFER_END

#endif

#endif
