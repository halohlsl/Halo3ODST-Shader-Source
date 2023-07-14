#ifndef _HUD_CAMERA_NIGHTVISION_REGISTERS_H_
#define _HUD_CAMERA_NIGHTVISION_REGISTERS_H_

#if DX_VERSION == 9

#define k_ps_hud_camera_nightvision_falloff 94
#define k_ps_hud_camera_nightvision_screen_to_world 95
#define k_ps_hud_camera_nightvision_ping 99
#define k_ps_hud_camera_nightvision_colors 100
#define k_ps_hud_camera_nightvision_overlapping_overdimming_factor 110
#define k_ps_hud_camera_nightvision_screenspace_xform 251

#elif DX_VERSION == 11

#define FX_FILE "rasterizer\\hlsl\\hud_camera_nightvision_registers.fx"
#include "rasterizer\dx11\rasterizer_dx11_define_fx_constants.h"
#undef FX_FILE

#endif

#endif
