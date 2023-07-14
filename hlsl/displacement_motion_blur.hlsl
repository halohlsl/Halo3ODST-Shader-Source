//#line 1 "source\rasterizer\hlsl\displacement_motion_blur.hlsl"

#include "global.fx"
#include "hlsl_constant_mapping.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"


#define DISTORTION_MULTISAMPLED 1
#define LDR_ONLY 1


#define LDR_ALPHA_ADJUST g_exposure.w
#define HDR_ALPHA_ADJUST g_exposure.b
#define DARK_COLOR_MULTIPLIER g_exposure.g
#include "render_target.fx"


#include "displacement_registers.fx"


//@generate screen
LOCAL_SAMPLER_2D(displacement_sampler, 0);
LOCAL_SAMPLER_2D_IN_VIEWPORT_ALLWAYS(ldr_buffer, 1);
#ifndef LDR_ONLY
LOCAL_SAMPLER_2D_IN_VIEWPORT_ALLWAYS(hdr_buffer, 2);
#endif

LOCAL_SAMPLER_2D_IN_VIEWPORT_ALLWAYS(distortion_depth_buffer, 3);


void default_vs(
	in vertex_type IN,
	out float4 position : SV_Position,
	out float4 iterator0 : TEXCOORD0)
{
    position.xy= IN.position;
    position.zw= 1.0f;

	float2 uncentered_texture_coords= position.xy * float2(0.5f, -0.5f) + 0.5f;							// uncentered means (0, 0) is the center of the upper left pixel
	float2 pixel_coords=	uncentered_texture_coords * vs_resolution_constants.xy;	// pixel coordinates are centered [0.5, resolution-0.5]
	float2 texture_coords=	uncentered_texture_coords;	// offset half a pixel to center these texture coordinates
	
	iterator0.xy= pixel_coords;
	iterator0.zw= texture_coords;
}

float4 tex2D_unnormalized(viewport_texture_sampler_2d texture_sampler, float2 unnormalized_texcoord)
{
	return sample2D(texture_sampler, unnormalized_texcoord * screen_constants.xy);
}


accum_pixel default_ps(
	SCREEN_POSITION_INPUT(screen_coords),
	in float4 iterator0 : TEXCOORD0)
{
	// unpack iterators
	float2 pixel_coords = iterator0.xy;
	
	float2 texture_coords= iterator0.zw;

	if (do_distortion)
	{
		float2 displacement= sample2D(displacement_sampler, texture_coords).xy * distort_constants.xy + distort_constants.zw;
		pixel_coords += displacement;
	}
	float2 pixel_coords_viewport = calc_viewport_pixel_coords_from_global_pixel_coords(pixel_coords);

	float4 center_color= tex2D_unnormalized(ldr_buffer, pixel_coords);
	float4 accum_color= float4(center_color.rgb, 1.0f);

	float2 crosshair_relative_position= calc_viewport_pixel_coords_from_global_pixel_coords(pixel_coords.xy * crosshair_constants.xy + crosshair_constants.zw);
	float center_falloff_scale_factor= saturate(dot(crosshair_relative_position.xy, crosshair_relative_position.xy));
	float combined_weight= saturate(center_color.a * center_falloff_scale_factor - 0.1f);
	
	if (combined_weight > 0.0f)
	{
		// fetch depth
		float4 depth = distortion_depth_buffer.t.Load(int3(pixel_coords_viewport.xy, 0));

		
		// calculate pixel coordinate for this pixel in the previous frame
		float4 previous_pixel_coords= mul(float4(pixel_coords.xy, depth.x, 1.0f), transpose(combined3));
		previous_pixel_coords.xy /= previous_pixel_coords.w;
		
		// scale and clamp the pixel delta
		float2 pixel_delta= pixel_coords_viewport.xy - calc_viewport_pixel_coords_from_global_pixel_coords(previous_pixel_coords.xy);
		float delta_length= sqrt(dot(pixel_delta, pixel_delta));			
		float scale= saturate(pixel_blur_constants.y / delta_length);
		
		// NOTE:  uv_delta.zw == 2 * uv_delta.xy    (the factor of 2 is stored in pixel_blur_constants.zw...  this is an optimization to save calculation later on)
		float4 uv_delta= pixel_blur_constants.zzww * pixel_delta.xyxy * scale * combined_weight;

		// the current pixel coordinates are offset by 1 and 2 deltas (we already have the original point sampled above)
		float4 current_pixel_coords= pixel_coords_viewport.xyxy + uv_delta.xyzw;
	
		{
			// sample twice in each loop to minimize loop overhead
			[isolate]
			[unroll]
			for (int i = 0; i < 3; ++ i)
			{
				// somehow, giving assembly to the compiler actually makes it alot smarter about GPRs
				float4 sample0 = ldr_buffer.t.Load(int3(clamp(current_pixel_coords.xy, ps_global_viewport_bounds_pixel.xy, ps_global_viewport_bounds_pixel.zw), 0));
				float4 sample1 = ldr_buffer.t.Load(int3(clamp(current_pixel_coords.zw, ps_global_viewport_bounds_pixel.xy, ps_global_viewport_bounds_pixel.zw), 0));
				current_pixel_coords += uv_delta.zwzw;
				accum_color.rgb += (sample0.rgb * sample0.a);
				accum_color.rgb += (sample1.rgb * sample1.a);
				accum_color.a += sample0.a;
				accum_color.a += sample1.a;
			}
		}
	}
	
	accum_pixel displaced_pixel;
	displaced_pixel.color.rgb= accum_color.rgb / accum_color.a;
	displaced_pixel.color.a= 0.0f;



	return displaced_pixel;
}
