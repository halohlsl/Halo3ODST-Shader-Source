#include "global.fx"
#include "hlsl_constant_mapping.fx"
#include "deform.fx"
#include "utilities.fx"

//@generate world
//@generate rigid
//@generate tiny_position

void default_vs(
	in vertex_type vertex,
	out float4 position : SV_Position,
	out float4 position_copy : TEXCOORD0)
{
	float4 local_to_world_transform[3];	
	always_local_to_view(vertex, local_to_world_transform, position);	
	position_copy= position;	
}

#if DX_VERSION == 9
float4 default_ps(SCREEN_POSITION_INPUT(screen_position), in float4 position : TEXCOORD0) : SV_Target
{
	return float4(position.z, position.z, position.z, 1.0f);
}
#elif DX_VERSION == 11
void default_ps()
{
}
#endif
