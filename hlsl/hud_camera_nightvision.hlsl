
#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
//@generate screen

#include "hud_camera_nightvision_registers.fx"

LOCAL_SAMPLER_2D(depth_sampler, 0);
#if DX_VERSION == 9
LOCAL_SAMPLER_2D(color_sampler, 1);
#elif DX_VERSION == 11
texture2D<uint2> stencil_texture : register(t1);
#endif
LOCAL_SAMPLER_2D(mask_sampler, 2);

#ifndef SCREENSPACE_TRANSFORM_TEXCOORD
#define SCREENSPACE_TRANSFORM_TEXCOORD(t) t
#endif

float3 calculate_world_position(float2 texcoord, float depth)
{
	float4 clip_space_position= float4(texcoord.xy, depth, 1.0f);
	float4 world_space_position= mul(clip_space_position, transpose(screen_to_world));
	return world_space_position.xyz / world_space_position.w;
}

float calculate_pixel_distance(float2 texcoord, float depth)
{
	float3 delta= calculate_world_position(texcoord, depth);
	float pixel_distance= sqrt(dot(delta, delta));
	return pixel_distance;
}

float evaluate_smooth_falloff(float distance)
{
//	constant 1.0, then smooth falloff to zero at a certain distance:
//
//	at distance D
//	has value (2^-C)		C=8  (1/256)
//	falloff sharpness S		S=8
//	let B= (C^(1/S))/D		stored in falloff.x
//	
//		equation:	f(x)=	2^(-(x*B)^S)			NOTE: for small S powers of 2, this can be expanded almost entirely in scalar ops
//

	return exp2(-pow(distance * falloff.x, 8));
}


float4 default_ps(screen_output IN) : SV_Target
{
#if defined(pc) && (DX_VERSION == 9)
 	float4 color= sample2D(depth_sampler, IN.texcoord);
#else

	float2 texcoord= IN.texcoord;
	
	// the HUD mask needs to be applied over the entire screen, so make sure to transform it when we're rendering tiles:
	float mask= sample2D(mask_sampler, SCREENSPACE_TRANSFORM_TEXCOORD(texcoord)).r;

	// active values:	mask, texcoord (3)
	
	float4 color= 0.0f;	
	if (mask > 0.0f)
	{
		float color_o;
		{
#ifdef xenon
			asm
			{
				tfetch2D color_o.x, texcoord, depth_sampler, OffsetX= 0, OffsetY= 0
			};	
#else
			color_o.x = sample2D(depth_sampler, texcoord).r;
#endif
		}
		
		// active values:	mask, texcoord, color_o, pulse_boost, index (5/6)

		float gradient_magnitude;
		float2 laplacian= float2(0,0);

		#ifdef COMPUTE_WIDE_FILTER	// Inlined code because "asm" keyword isn't supported in HLSL functions. Go figure. 
		{
			// A 7x7 Laplacian filter:
			float weights[7]= {1, 1, 1, -6, 1, 1, 1};
			float color_x[7];
			float color_y[7];
#ifdef xenon			
			asm
			{
				// Sample in X:
				tfetch2D color_x[0].x, texcoord, depth_sampler, OffsetX= -3, OffsetY= 0
				tfetch2D color_x[1].x, texcoord, depth_sampler, OffsetX= -2, OffsetY= 0
				tfetch2D color_x[2].x, texcoord, depth_sampler, OffsetX= -1, OffsetY= 0
				tfetch2D color_x[4].x, texcoord, depth_sampler, OffsetX=  1, OffsetY= 0
				tfetch2D color_x[5].x, texcoord, depth_sampler, OffsetX=  2, OffsetY= 0
				tfetch2D color_x[6].x, texcoord, depth_sampler, OffsetX=  3, OffsetY= 0
				
				// Sample in X:
				tfetch2D color_y[0].x, texcoord, depth_sampler, OffsetX= 0, OffsetY= -3
				tfetch2D color_y[1].x, texcoord, depth_sampler, OffsetX= 0, OffsetY= -2
				tfetch2D color_y[2].x, texcoord, depth_sampler, OffsetX= 0, OffsetY= -1
				tfetch2D color_y[4].x, texcoord, depth_sampler, OffsetX= 0, OffsetY=  1
				tfetch2D color_y[5].x, texcoord, depth_sampler, OffsetX= 0, OffsetY=  2
				tfetch2D color_y[6].x, texcoord, depth_sampler, OffsetX= 0, OffsetY=  3
				
			};
#else
			color_x[0] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(-3, 0)).x;
			color_x[1] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(-2, 0)).x;
			color_x[2] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(-1, 0)).x;
			color_x[4] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(1, 0)).x;
			color_x[5] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(2, 0)).x;
			color_x[6] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(3, 0)).x;
			
			color_y[0] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, -3)).x;
			color_y[1] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, -2)).x;
			color_y[2] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, -1)).x;
			color_y[4] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, 1)).x;
			color_y[5] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, 2)).x;
			color_y[6] = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, 3)).x;
#endif			
			color_x[3]= color_y[3]= color_o;	// center

			for (int i= 0; i < 7; i++)
			{
				laplacian.x+= weights[i] * color_x[i];
				laplacian.y+= weights[i] * color_y[i];
			}
			gradient_magnitude= saturate(sqrt(dot(laplacian.xy, laplacian.xy)) / color_o.r);	
		}
		#else
			{
				float color_px, color_nx;
				float color_py, color_ny;
				
#ifdef xenon				
				asm
				{
					tfetch2D color_px.x, texcoord, depth_sampler, OffsetX= 1, OffsetY= 0
					tfetch2D color_nx.x, texcoord, depth_sampler, OffsetX= -1, OffsetY= 0
					tfetch2D color_py.x, texcoord, depth_sampler, OffsetX= 0, OffsetY= 1
					tfetch2D color_ny.x, texcoord, depth_sampler, OffsetX= 0, OffsetY= -1
				};
#else
				color_px = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(1, 0)).x;
				color_nx = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(-1, 0)).x;
				color_py = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, 1)).x;
				color_ny = depth_sampler.t.Sample(depth_sampler.s, texcoord, int2(0, -1)).x;
#endif				

				laplacian.x= (color_px + color_nx) - 2 * color_o;
				laplacian.y= (color_py + color_ny) - 2 * color_o;

				gradient_magnitude= saturate(sqrt(dot(laplacian.xy, laplacian.xy)) / color_o);			
			}
		#endif

		if (gradient_magnitude > (1.0 / 255.0))
		{
			// active values:	mask, texcoord, color_o (4)

			float4 color0;
			float4 color1;
			
			int index;
			float pulse_boost;
			[isolate]
			{
				float value;
#ifdef xenon			
				asm
				{
					tfetch2D value.b, texcoord, color_sampler, OffsetX= 0, OffsetY= 0
				};	
#elif DX_VERSION == 11
				float2 stencil_dim;
				stencil_texture.GetDimensions(stencil_dim.x, stencil_dim.y);

#ifdef durango
				// G8 SRVs are broken on Durango - components are swapped
				uint raw_stencil = stencil_texture.Load(int3(texcoord * stencil_dim, 0)).r;
#else
				uint raw_stencil = stencil_texture.Load(int3(texcoord * stencil_dim, 0)).g;
#endif			
				index = (raw_stencil + 32) >> 6;				
#else
				value = sample2D(color_sampler, texcoord).b;
				index= floor(value * 4 + 0.5f);				
#endif
			
				color0 = colors[index][0];
				color1 = colors[index][1];
				
				if (laplacian.x + laplacian.y > 0)
				{
					gradient_magnitude*= color1.a;	//overlapping_dimming_factor[index];
				}				
			
				float pixel_distance= calculate_pixel_distance(texcoord, color_o);
				mask *= evaluate_smooth_falloff(pixel_distance);
				// calculate pulse
				{
					float ping_distance= ping.x;
					float after_ping= (ping_distance - pixel_distance);		// 0 at wavefront, positive closer to player
					pulse_boost= pow(saturate(1.0f + ping.z * after_ping), 4.0f) * step(pixel_distance, ping_distance);
					
					float clip_distance= ping.y;
					mask *= step(pixel_distance, clip_distance);			
				}
			}

			// active values:	mask, pulse_boost, index (2/3)
			{
				// convert to [0..4]
				float3 pulse_color= color1.rgb;	//colors[index][1];
				float4 default_color= color0;	//colors[index][0];
				
				color.rgb= gradient_magnitude * (default_color.rgb + pulse_color.rgb * pulse_boost);
				color.a= default_color.a * LDR_ALPHA_ADJUST;
				
				color *= mask;
			}
		} else		
		{
			discard;
		}
	} else
	{
		discard;
	}
#endif

	return color;
}
