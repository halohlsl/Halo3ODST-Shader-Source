#ifndef _LENS_FLARE_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _LENS_FLARE_REGISTERS_FX_
#endif

#if DX_VERSION == 9

#include "lens_flare_registers.h"

// x is modulation factor, y is tint power, z is brightness, w unused
PIXEL_CONSTANT(float4, modulation_factor, k_ps_lens_flare_modulation_factor);
PIXEL_CONSTANT(float4, tint_color, k_ps_lens_flare_tint_color);
VERTEX_CONSTANT(float4, center_rotation, k_vs_lens_flare_center_rotation);		// center(x,y), theta
VERTEX_CONSTANT(float4, flare_scale, k_vs_lens_flare_scale);			// scale(x, y), global scale

#elif DX_VERSION == 11

CBUFFER_BEGIN(LensFlareVS)
	CBUFFER_CONST(LensFlareVS,		float4,		center_rotation,		k_vs_lens_flare_center_rotation)
	CBUFFER_CONST(LensFlareVS,		float4,		flare_scale,			k_vs_lens_flare_scale)
CBUFFER_END

CBUFFER_BEGIN(LensFlarePS)
	CBUFFER_CONST(LensFlarePS,		float4,		modulation_factor,		k_ps_lens_flare_modulation_factor)
	CBUFFER_CONST(LensFlarePS,		float4,		tint_color,				k_ps_lens_flare_tint_color)
CBUFFER_END

#endif

#endif
