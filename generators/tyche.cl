/**
@file

Implements a 512-bit tyche (Well-Equidistributed Long-period Linear) RNG.

S. Neves, F. Araujo, Fast and small nonlinear pseudorandom number generators for computer simulation, in: International Conference on Parallel Processing and Applied Mathematics, Springer, 2011, pp. 92–101.
*/
#pragma once

#define TYCHE_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define TYCHE_DOUBLE_MULTI 5.4210108624275221700372640e-20

/**
State of tyche RNG.
*/
typedef union{
	struct{
		uint a,b,c,d;
	};
	ulong res;
} tyche_state;

#define TYCHE_ROT(a,b) (((a) << (b)) | ((a) >> (32 - (b))))

/**
Generates a random 64-bit unsigned integer using tyche RNG.

This is alternative, macro implementation of tyche RNG.

@param state State of the RNG to use.
*/
#define tyche_macro_ulong(state) (tyche_macro_advance(state), state.res)
#define tyche_macro_advance(state) ( \
	state.a += state.b, \
	state.d = TYCHE_ROT(state.d ^ state.a, 16), \
	state.c += state.d, \
	state.b = TYCHE_ROT(state.b ^ state.c, 12), \
	state.a += state.b, \
	state.d = TYCHE_ROT(state.d ^ state.a, 8), \
	state.c += state.d, \
	state.b = TYCHE_ROT(state.b ^ state.c, 7) \
)

/**
Generates a random 64-bit unsigned integer using tyche RNG.

@param state State of the RNG to use.
*/
#define tyche_ulong(state) (tyche_advance(&state), state.res)
void tyche_advance(tyche_state* state){
	state->a += state->b;
	state->d = TYCHE_ROT(state->d ^ state->a, 16);
	state->c += state->d;
	state->b = TYCHE_ROT(state->b ^ state->c, 12);
	state->a += state->b;
	state->d = TYCHE_ROT(state->d ^ state->a, 8);
	state->c += state->d;
	state->b = TYCHE_ROT(state->b ^ state->c, 7);
}

/**
Seeds tyche RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void tyche_seed(tyche_state* state, ulong seed){
	state->a = seed >> 32;
	state->b = seed;
	state->c = 2654435769;
	state->d = 1367130551 ^ (get_global_id(0) + get_global_size(0) * (get_global_id(1) + get_global_size(1) * get_global_id(2)));
	for(uint i=0;i<20;i++){
		tyche_advance(state);
	}
}

/**
Generates a random 32-bit unsigned integer using tyche RNG.

@param state State of the RNG to use.
*/
#define tyche_uint(state) ((uint)tyche_ulong(state))

/**
Generates a random float using tyche RNG.

@param state State of the RNG to use.
*/
#define tyche_float(state) (tyche_ulong(state)*TYCHE_FLOAT_MULTI)

/**
Generates a random double using tyche RNG.

@param state State of the RNG to use.
*/
#define tyche_double(state) (tyche_ulong(state)*TYCHE_DOUBLE_MULTI)

/**
Generates a random double using tyche RNG. Since tyche returns 64-bit numbers this is equivalent to tyche_double.

@param state State of the RNG to use.
*/
#define tyche_double2(state) tyche_double(state)