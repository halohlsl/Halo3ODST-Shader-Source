#ifndef _DISPLACEMENT_REGISTERS_H_
#define _DISPLACEMENT_REGISTERS_H_

#if DX_VERSION == 9

#ifndef CONSTANT_NAME
#define CONSTANT_NAME(n) n
#endif

#define k_vs_displacement_resolution_constants CONSTANT_NAME(250)

#define k_ps_displacement_screen_constants CONSTANT_NAME(203)
#define k_ps_displacement_distort_constants CONSTANT_NAME(205)
#define k_ps_displacement_window_bounds CONSTANT_NAME(204)
#define k_ps_displacement_combined3 CONSTANT_NAME(188)
#define k_ps_displacement_pixel_blur_constants CONSTANT_NAME(158)
#define k_ps_displacement_crosshair_constants CONSTANT_NAME(209)
#define k_ps_displacement_do_distortion 2

#elif DX_VERSION == 11

#define FX_FILE "rasterizer\\hlsl\\displacement_registers.fx"
#include "rasterizer\dx11\rasterizer_dx11_define_fx_constants.h"
#undef FX_FILE

#endif

#endif