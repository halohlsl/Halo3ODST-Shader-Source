/*
PARTICLE_UPDATE_REGISTERS.FX
Copyright (c) Microsoft Corporation, 2005. all rights reserved.
12/5/2005 11:50:57 AM (davcook)
	
*/

#ifdef PC_CPU

float    delta_time;
float4   hidden_from_compiler;
float4x3 tile_to_world;
float4x3 world_to_tile;
float4x3 occlusion_to_world;
float4x3 world_to_occlusion;
BOOL     tiled;
BOOL     collision;
   
#elif DX_VERSION == 9

#include "particle_update_registers.h"

VERTEX_CONSTANT(float, delta_time, k_vs_particle_update_delta_time)
VERTEX_CONSTANT(float4, hidden_from_compiler, k_vs_particle_update_hidden_from_compiler)	// the compiler will complain if these are literals
VERTEX_CONSTANT(float4x3, tile_to_world, k_vs_particle_update_tile_to_world)	//= {float3x3(Camera_Forward, Camera_Left, Camera_Up) * tile_size, Camera_Position};
VERTEX_CONSTANT(float4x3, world_to_tile, k_vs_particle_update_world_to_tile)	//= {transpose(float3x3(Camera_Forward, Camera_Left, Camera_Up) * inverse_tile_size), -Camera_Position};
VERTEX_CONSTANT(float4x3, occlusion_to_world, k_vs_particle_update_occlusion_to_world)
VERTEX_CONSTANT(float4x3, world_to_occlusion, k_vs_particle_update_world_to_occlusion)	
BOOL_CONSTANT(tiled, k_vs_particle_update_tiled)
BOOL_CONSTANT(collision, k_vs_particle_update_collision)   

#elif DX_VERSION == 11

#include "particle_property.fx"
#include "function_definition.fx"
#include "particle_state_list.fx"
#include "particle_update_state.fx"
#include "particle_row_buffer.fx"

#ifndef DEFINED_PARTICLE_ROW_CONSTANTS
#define DEFINED_PARTICLE_ROW_CONSTANTS
static const uint k_particle_row_count_bits = 4;
static const uint k_particle_row_update_params_bits = 14;
static const uint k_particle_row_const_params_bits = 14;
#endif

#define CS_PARTICLE_UPDATE_THREADS 64

CBUFFER_BEGIN(ParticleUpdateVS)
	CBUFFER_CONST(ParticleUpdateVS,			float,					delta_time,						k_vs_particle_update_delta_time)
	CBUFFER_CONST(ParticleUpdateVS,			float3,					delta_time_pad,					k_vs_particle_update_delta_time_pad)
	CBUFFER_CONST(ParticleUpdateVS,			float4,					hidden_from_compiler,			k_vs_particle_update_hidden_from_compiler)
	CBUFFER_CONST(ParticleUpdateVS,			float4x3,				occlusion_to_world,				k_vs_particle_update_occlusion_to_world)
	CBUFFER_CONST(ParticleUpdateVS,			float4x3,				world_to_occlusion,				k_vs_particle_update_world_to_occlusion)	
CBUFFER_END

COMPUTE_TEXTURE_AND_SAMPLER(_2D,			sampler_weather_occlusion,		k_cs_sampler_weather_occlusion,			1)

STRUCTURED_BUFFER(update_params_buffer,	k_cs_particle_update_params_buffer, 	s_particle_system_update_params,	5)
STRUCTURED_BUFFER(const_params_buffer,	k_cs_particle_const_params_buffer, 		s_particle_system_const_params,		6)

#if (DX_VERSION == 11) && (! defined(DEFINE_CPP_CONSTANTS))
static const uint k_particle_row_shift = 4;
static const uint k_particle_row_mask = 0xf;
static const uint k_particle_update_params_shift = k_particle_row_count_bits;
static const uint k_particle_update_params_mask = (1 << k_particle_row_update_params_bits) - 1;
static const uint k_particle_const_params_shift = k_particle_update_params_shift + k_particle_row_update_params_bits;
static const uint k_particle_const_params_mask = (1 << k_particle_row_const_params_bits) - 1;

static uint g_update_params_index;
static uint g_const_params_index;

#define g_all_properties const_params_buffer[g_const_params_index].all_properties
#define g_all_functions const_params_buffer[g_const_params_index].all_functions
#define g_all_colors const_params_buffer[g_const_params_index].all_colors
#define g_all_state update_params_buffer[g_update_params_index].all_state
#define g_update_state update_params_buffer[g_update_params_index].update_state
#define tile_to_world update_params_buffer[g_update_params_index].tile_to_world_
#define world_to_tile update_params_buffer[g_update_params_index].world_to_tile_
#define tiled update_params_buffer[g_update_params_index].tiled_
#define collision update_params_buffer[g_update_params_index].collision_
#endif

#endif
