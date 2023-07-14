#ifndef _HUD_CAMERA_REGISTERS_H_
#define _HUD_CAMERA_REGISTERS_H_

#if DX_VERSION == 9

#define k_ps_hud_camera_colors 100

#elif DX_VERSION == 11

#define FX_FILE "rasterizer\\hlsl\\hud_camera_registers.fx"
#include "rasterizer\dx11\rasterizer_dx11_define_fx_constants.h"
#undef FX_FILE

#endif

#endif
