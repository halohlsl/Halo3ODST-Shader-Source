#line 2 "source\rasterizer\hlsl\downsample_4x4_gaussian_bloom.hlsl"


#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
#include "downsample_registers.fx"
//@generate screen


LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(dark_source_sampler, 0);



float4 default_ps(screen_output IN) : SV_Target
{
#ifdef pc
	float3 color= 0.00000001f;						// hack to keep divide by zero from happening on the nVidia cards
#else
	float3 color= 0.0f;
#endif

	float4 sample;

	// this is a 6x6 gaussian filter (slightly better than 4x4 box filter)	
/*	sample= tex2D_offset(dark_source_sampler, IN.texcoord, -2, -2);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +0, -2);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +2, -2);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, -2, +0);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +0, +0);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +2, +0);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, -2, +2);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +0, +2);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +2, +2);
		color += (0.33f * 0.33f) * sample.rgb * sample.rgb;
	color= color * DARK_COLOR_MULTIPLIER;
*/

	float sample_intensity, sample_curved;
	float intensity= 0;
	
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, -1, -1);
		sample.rgb *= sample.rgb * DARK_COLOR_MULTIPLIER;
		sample_intensity= dot(sample.rgb, intensity_vector.rgb);
		intensity += sample_intensity * 0.25f;
		sample_curved= max(sample_intensity*ps_postprocess_scale.y, sample_intensity-ps_postprocess_scale.x);		// ###ctchou $PERF could compute both parameters with a single mad followed by max
		color += sample.rgb * sample_curved / sample_intensity;

	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +1, -1);
		sample.rgb *= sample.rgb * DARK_COLOR_MULTIPLIER;
		sample_intensity= dot(sample.rgb, intensity_vector.rgb);
		intensity += sample_intensity * 0.25f;
		sample_curved= max(sample_intensity*ps_postprocess_scale.y, sample_intensity-ps_postprocess_scale.x);		// ###ctchou $PERF could compute both parameters with a single mad followed by max
		color += sample.rgb * sample_curved / sample_intensity;

	sample= tex2D_offset(dark_source_sampler, IN.texcoord, -1, +1);
		sample.rgb *= sample.rgb * DARK_COLOR_MULTIPLIER;
		sample_intensity= dot(sample.rgb, intensity_vector.rgb);
		intensity += sample_intensity * 0.25f;
		sample_curved= max(sample_intensity*ps_postprocess_scale.y, sample_intensity-ps_postprocess_scale.x);		// ###ctchou $PERF could compute both parameters with a single mad followed by max
		color += sample.rgb * sample_curved / sample_intensity;

	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +1, +1);
		sample.rgb *= sample.rgb * DARK_COLOR_MULTIPLIER;
		sample_intensity= dot(sample.rgb, intensity_vector.rgb);
		intensity += sample_intensity * 0.25f;
		sample_curved= max(sample_intensity*ps_postprocess_scale.y, sample_intensity-ps_postprocess_scale.x);		// ###ctchou $PERF could compute both parameters with a single mad followed by max
		color += sample.rgb * sample_curved / sample_intensity;

	color= color / 4.0f;
	float3 bloom_color= color;

/*	float4 sample= tex2D_offset(dark_source_sampler, IN.texcoord, -1, -1);
		color += sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +1, -1);
		color += sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, -1, +1);
		color += sample.rgb * sample.rgb;
	sample= tex2D_offset(dark_source_sampler, IN.texcoord, +1, +1);
		color += sample.rgb * sample.rgb;
	color= color * DARK_COLOR_MULTIPLIER / 4.0f;
*/		
/*
	// calculate 'intensity'		(max or dot product?)
	float intensity= dot(color.rgb, intensity_vector.rgb);					// max(max(color.r, color.g), color.b);
	
	// calculate bloom curve intensity
	float bloom_intensity= max(intensity*ps_postprocess_scale.y, intensity-ps_postprocess_scale.x);		// ###ctchou $PERF could compute both parameters with a single mad followed by max
	
	// calculate bloom color
	float3 bloom_color= color * (bloom_intensity / intensity);
*/
	return float4(bloom_color.rgb, intensity);
}
