#line 1 "source\rasterizer\hlsl\screenshot_combine.hlsl"

//@generate screen

#include "global.fx"

#define CALC_BLOOM calc_bloom_screenshot
float4 calc_bloom_screenshot(in float2 texcoord);

#define SCREENSPACE_TRANSFORM_COORDS(t) transform_texcoord(t, screenspace_sampler_xform)


#include "final_composite_base.hlsl"

float4 calc_bloom_screenshot(in float2 texcoord)
{		
	// sample bloom super-smooth bspline!
	return tex2D_bspline(bloom_sampler, texcoord);
}


