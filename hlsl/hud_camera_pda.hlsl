#line 2 "source\rasterizer\hlsl\hud_camera_pda.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
//@generate screen

#include "hud_camera_registers.fx"

LOCAL_SAMPLER_2D(source_sampler,  0);
#if DX_VERSION == 9
LOCAL_SAMPLER_2D(color_sampler, 1);
#elif DX_VERSION == 11
texture2D<uint2> stencil_texture : register(t1);
#endif

float4 default_ps(screen_output IN) : SV_Target
{
#if defined(pc) && (DX_VERSION == 9)
 	float4 color= sample2D(source_sampler, IN.texcoord);
#else

	float2 texcoord= IN.texcoord;
	float2 gradient;
	float4 color_o;
	{
		float4 color_nx, color_ny;
#ifdef xenon		
		asm
		{
			tfetch2D color_o, texcoord, source_sampler, OffsetX= 0, OffsetY= 0
			tfetch2D color_nx, texcoord, source_sampler, OffsetX= -1, OffsetY= 0
			tfetch2D color_ny, texcoord, source_sampler, OffsetX= 0, OffsetY= -1
		};
#else
		color_o = sample2D(source_sampler, texcoord);
		color_nx = source_sampler.t.Sample(source_sampler.s, texcoord, int2(-1, 0));
		color_ny = source_sampler.t.Sample(source_sampler.s, texcoord, int2(0, -1));
#endif		
		gradient.x=	(color_o.r - color_nx.r);
		gradient.y=	(color_o.r - color_ny.r);
	}
	
	float gradient_magnitude= sqrt(dot(gradient.xy, gradient.xy) + 0.00000000000003f) / color_o.r;		// the really small constant controls how bright the image is at distance.  very small because it is relative to color_o

	float4 color;
#ifdef xenon	
	asm
	{
		tfetch2D color, texcoord, color_sampler, OffsetX= 0, OffsetY= 0
	};
#else
	float2 stencil_dim;
	stencil_texture.GetDimensions(stencil_dim.x, stencil_dim.y);	
	
#ifdef durango
			// G8 SRVs are broken on Durango - components are swapped
	uint raw_stencil = stencil_texture.Load(int3(texcoord * stencil_dim, 0)).r;
#else
	uint raw_stencil = stencil_texture.Load(int3(texcoord * stencil_dim, 0)).g;
#endif		

	color = raw_stencil / 255.0f;	
#endif	
	
	// convert to [0..4]
	color= colors[floor(color.b * 4 + 0.5f)];
	color.rgb *= saturate(gradient_magnitude * 25.6 + 0.06f) / 256;		 //		the 0.06 controls how bright the image is up close
	color.a *= LDR_ALPHA_ADJUST;

#endif
	return color;
}
