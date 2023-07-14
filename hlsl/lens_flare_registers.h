#ifndef _LENS_FLARE_REGISTERS_H_
#define _LENS_FLARE_REGISTERS_H_

#if DX_VERSION == 9

#ifndef CONSTANT_NAME
#define CONSTANT_NAME(n) n
#endif

#define k_ps_lens_flare_modulation_factor CONSTANT_NAME(50)
#define k_ps_lens_flare_tint_color CONSTANT_NAME(51)
#define k_vs_lens_flare_center_rotation CONSTANT_NAME(240)
#define k_vs_lens_flare_scale CONSTANT_NAME(241)

#elif DX_VERSION == 11

#define FX_FILE "rasterizer\\hlsl\\lens_flare_registers.fx"
#include "rasterizer\dx11\rasterizer_dx11_define_fx_constants.h"
#undef FX_FILE

#endif

#endif
