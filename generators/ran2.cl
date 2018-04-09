/**
@file

Implements a ran2 RNG.
*/
#pragma once

#define RAN2_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define RAN2_DOUBLE_MULTI 5.4210108624275221700372640e-20

/**
State of ran2 RNG.
*/
typedef struct {
	ulong u,v,w;
} ran2_state;

#define ran2_SH1(x) ((x) ^ ((x) << 21))
#define ran2_SH2(x) ((x) ^ ((x) >> 35))
#define ran2_SH3(x) ((x) ^ ((x) << 4 ))
/**
Generates a random 64-bit unsigned integer using ran2 RNG.

This is alternative, macro implementation of WELL RNG.

@param state State of the RNG to use.
*/
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

/**
Generates a random 64-bit unsigned integer using ran2 RNG.

@param state State of the RNG to use.
*/
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

/**
Seeds ran2 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
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

/**
Generates a random 32-bit unsigned integer using ran2 RNG.

@param state State of the RNG to use.
*/
#define ran2_uint(state) ((uint)ran2_ulong(state))

/**
Generates a random float using ran2 RNG.

@param state State of the RNG to use.
*/
#define ran2_float(state) (ran2_ulong(state)*RAN2_FLOAT_MULTI)

/**
Generates a random double using ran2 RNG.

@param state State of the RNG to use.
*/
#define ran2_double(state) (ran2_ulong(state)*RAN2_DOUBLE_MULTI)

/**
Generates a random double using ran2 RNG. Since ran2 returns 64-bit numbers this is equivalent to ran2_double.

@param state State of the RNG to use.
*/
#define ran2_double2(state) ran2_double(state)