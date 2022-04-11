#line 1 "source\rasterizer\hlsl\hud_camera_nightvision_screenshot.hlsl"
//@generate screen


#define COMPUTE_WIDE_FILTER

#define SCREENSPACE_TRANSFORM_TEXCOORD(t) t * screenspace_xform.xy + screenspace_xform.zw

#include "hud_camera_nightvision.hlsl"

