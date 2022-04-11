#ifndef _STIPPLE_FX_
#define _STIPPLE_FX_

#if DX_VERSION == 11
void stipple_test(in float2 screen_position)
{
	float stipple = stipple_texture.Load(uint3(uint2(screen_position.xy)&7, 0)).r;
	clip(stipple_threshold - stipple);
}
#endif

#endif
