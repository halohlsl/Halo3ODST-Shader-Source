#line 2 "source\rasterizer\hlsl\pixel_copy.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
//@generate screen

LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(source_sampler, 0);

float4 default_ps(screen_output IN, SCREEN_POSITION_INPUT(vpos)) : SV_Target
{
 	return sample2D(source_sampler, IN.texcoord * ps_postprocess_scale.xy);
}
