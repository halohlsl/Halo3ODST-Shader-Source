#ifndef _PARTICLE_UPDATE_STATE_FX_
#define _PARTICLE_UPDATE_STATE_FX_

#if DX_VERSION == 9

struct s_update_state
{
	PADDED(float, 1, m_gravity)
	PADDED(float, 1, m_air_friction)
	PADDED(float, 1, m_rotational_friction)
};

#elif DX_VERSION == 11

struct s_update_state
{
	float m_gravity;
	float m_air_friction;
	float m_rotational_friction;
};

struct s_gpu_single_state_update
{
	float m_value;
};

struct s_all_state_update
{
	s_gpu_single_state_update m_inputs[_state_total_count];
};

struct s_particle_system_const_params
{
	s_property all_properties[_index_max];
	s_function_definition all_functions[_maximum_overall_function_count];
	float4 all_colors[_maximum_overall_color_count];
};

struct s_particle_system_update_params
{
	bool tiled_;
	float4x3 tile_to_world_;
	float4x3 world_to_tile_;	

	bool collision_;
	
	s_all_state_update all_state;
	s_update_state update_state;
	
};

#endif

#endif
