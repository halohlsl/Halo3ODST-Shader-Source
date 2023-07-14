#ifndef _PARTICLE_SPAWN_REGISTERS_H_
#define _PARTICLE_SPAWN_REGISTERS_H_

#if DX_VERSION == 9

#ifndef CONSTANT_NAME
#define CONSTANT_NAME(n) n
#endif

#define k_vs_particle_spawn_hidden_from_compiler CONSTANT_NAME(32)

#elif DX_VERSION == 11

#define FX_FILE "rasterizer\\hlsl\\particle_spawn_registers.fx"
#include "rasterizer\dx11\rasterizer_dx11_define_fx_constants.h"
#undef FX_FILE

#endif

#endif
