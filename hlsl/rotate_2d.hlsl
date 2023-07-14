#line 2 "source\rasterizer\hlsl\rotate_2d.hlsl"

//#define USE_CUSTOM_POSTPROCESS_CONSTANTS

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
#include "rotate_2d_registers.fx"
//@generate screen

LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(source_sampler, 0);
LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(background_sampler, 1);

// pixel fragment entry points
float4 default_ps(screen_output IN) : SV_Target
{
	float2 rotated_texcoord;
	rotated_texcoord.x= dot(ps_postprocess_scale.xy, IN.texcoord.xy) + offset.x;
	rotated_texcoord.y= dot(ps_postprocess_scale.zw, IN.texcoord.xy) + offset.y;
	
	float4 source=		sample2D(source_sampler,			rotated_texcoord);

	float4 background;
	background=	sample2D(background_sampler, IN.texcoord);

	return background + source;
}
