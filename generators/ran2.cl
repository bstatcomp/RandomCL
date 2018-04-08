#pragma once

#define RAN2_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define RAN2_DOUBLE_MULTI 5.4210108624275221700372640e-20

typedef struct {
	ulong u,v,w;
} ran2_state;

#define ran2_SH1(x) ((x) ^ ((x) << 21))
#define ran2_SH2(x) ((x) ^ ((x) >> 35))
#define ran2_SH3(x) ((x) ^ ((x) << 4 ))
#define ran2_macro_ulong(state) (\
	state.u = state.u * 2862933555777941757UL + 7046029254386353087UL, \
	\
	state.v ^= state.v >> 17, \
	state.v ^= state.v << 31, \
	state.v ^= state.v >> 8, \
	\
	state.w = 4294957665U * (state.w & 0xffffffff) + (state.w >> 32), \
	\
	(ran2_SH3(ran2_SH2(ran2_SH1(state.u))) + state.v) ^ state.w \
	)

#define ran2_ulong(state) _ran2_ulong(&state)
	
ulong _ran2_ulong(ran2_state* state){
	state->u = state->u * 2862933555777941757UL + 7046029254386353087UL;
	
	state->v ^= state->v >> 17;
	state->v ^= state->v << 31;
	state->v ^= state->v >> 8;
	
	state->w = 4294957665U * (state->w & 0xffffffff) + (state->w >> 32);
	
	ulong x = state->u ^ (state->u << 21);
	x ^= x >> 35;
	x ^= x << 4;
	return (x + state->v) ^ state->w;
}
/*double ran2_double(ran2_state* state){
	return RAN2_DOUBLE_MULTI * ran2_long(state);
}*/

void ran2_seed(ran2_state* state, ulong j){
	state->u = j^4101842887655102017UL;
	if(state->u == 0){
		state->u += get_global_size(0)*get_global_size(1)*get_global_size(2);
	}
	_ran2_ulong(state);
	state->v = state->u;
	_ran2_ulong(state);
	state->w = state->v;
	_ran2_ulong(state);
}

#define ran2_uint(state) ((uint)ran2_ulong(state))
#define ran2_float(state) (ran2_ulong(state)*RAN2_FLOAT_MULTI)
#define ran2_double(state) (ran2_ulong(state)*RAN2_DOUBLE_MULTI)
#define ran2_double2(state) ran2_double(state)