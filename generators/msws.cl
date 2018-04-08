#pragma once

#define MSWS_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define MSWS_DOUBLE_MULTI 5.4210108624275221700372640e-20

typedef struct{
	union{
		ulong x;
		uint2 x2;
	};
	ulong w;
}msws_state;

#define msws_macro_ulong(state) (\
	state.x *= state.x, \
	state.x += (state.w += 0xb5ad4eceda1ce2a9), \
	state.x = (state.x>>32) | (state.x<<32) \
	)

#define msws_ulong(state) _msws_ulong(&state)
	
ulong _msws_ulong(msws_state* state){
	state->x *= state->x;
	state->x += (state->w += 0xb5ad4eceda1ce2a9);
	return state->x = (state->x>>32) | (state->x<<32);
}

#define msws_swap_ulong(state) _msws_swap_ulong(&state)
ulong _msws_swap_ulong(msws_state* state){
	state->x *= state->x;
	state->x += (state->w += 0xb5ad4eceda1ce2a9);
	/*uint tmp = state->xl;
	state->xl = state->xh;
	state->xh = tmp;*/
	state->x2 = state->x2.yx;
	return state->x;
}

#define msws_swap2_ulong(state) _msws_swap2_ulong(&state)
ulong _msws_swap2_ulong(msws_state* state){
	state->x *= state->x;
	state->x += (state->w += 0xb5ad4eceda1ce2a9);
	uint tmp = state->x2.x;
	state->x2.x = state->x2.y;
	state->x2.y = tmp;
	return state->x;
}

void msws_seed(msws_state* state, ulong j){
	state->x = j;
	state->w = j;
}

#define msws_uint(state) ((uint)msws_ulong(state))
#define msws_float(state) (msws_ulong(state)*MSWS_FLOAT_MULTI)
#define msws_double(state) (msws_ulong(state)*MSWS_DOUBLE_MULTI)
#define msws_double2(state) msws_double(state)