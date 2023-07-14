#ifndef __DOF_FILTER_FX
#define __DOF_FILTER_FX


float4 simple_DOF_filter(float2 vTexCoord, viewport_texture_sampler_2d original_sampler, bool original_gamma2, viewport_texture_sampler_2d blurry_sampler, viewport_texture_sampler_2d zbuffer_sampler)
{
	// Fetch high and low resolution taps
	float4 vTapLow = sample2D(blurry_sampler, vTexCoord - (ps_postprocess_pixel_size.zw - ps_postprocess_pixel_size.xy) * 0.0f);
	float4 vTapHigh=	sample2D( original_sampler, vTexCoord );
	if (original_gamma2)
	{
		vTapHigh.rgb *= vTapHigh.rgb;
	}

	// get pixel depth, and calculate blur amount
	float fCenterDepth = sample2D( zbuffer_sampler, vTexCoord ).r;
	fCenterDepth= 1.0f / (DEPTH_BIAS + fCenterDepth * DEPTH_SCALE);					// convert to real depth
	float fTapBlur = min(max(abs(fCenterDepth-FOCUS_DISTANCE)-FOCUS_HALF_WIDTH, 0.0f)*APERTURE, MAX_BLUR_BLEND);

	// blend high and low res based on blur amount
	float4 vOutColor= lerp(vTapHigh, vTapLow, fTapBlur * fTapBlur);							// blurry samples use blurry buffer,  sharp samples use sharp buffer

    return vOutColor; 
}


#endif
