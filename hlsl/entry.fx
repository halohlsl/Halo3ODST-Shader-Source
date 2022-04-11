
#define ENTRY_POINT(name) ENTRY_POINT_##name

#define ENTRY_POINT_default 0
#define ENTRY_POINT_albedo 1
#define ENTRY_POINT_static_default 2
#define ENTRY_POINT_static_per_pixel 3
#define ENTRY_POINT_static_per_vertex 4
#define ENTRY_POINT_static_sh 5
#define ENTRY_POINT_static_prt_ambient 6
#define ENTRY_POINT_static_prt_linear 7
#define ENTRY_POINT_static_prt_quadratic 8
#define ENTRY_POINT_dynamic_light 9
#define ENTRY_POINT_shadow_generate 10
#define ENTRY_POINT_shadow_apply 11
#define ENTRY_POINT_debug_radiance_map 12
#define ENTRY_POINT_static_per_vertex_color 13
#define ENTRY_POINT_lightmap_debug_mode 14
#define ENTRY_POINT_dynamic_light_cinematic 15
