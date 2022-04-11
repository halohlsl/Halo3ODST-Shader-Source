#line 2 "source\rasterizer\hlsl\stencil_depth_fail.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
//@generate screen

struct screen_output
{
    float4 position	:SV_Position;
};

screen_output default_vs(vertex_type IN)
{
	screen_output OUT;
	OUT.position = float4(IN.position, 0, 1);
	return OUT;	
}

float4 default_ps(screen_output IN) : SV_Target
{
	return 0;
}
