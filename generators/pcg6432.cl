/**
@file

Implements a 64-bit Permutated Congruential generator (PCG-XSH-RR).
*/

#pragma once

#define RNG32

#define PCG6432_FLOAT_MULTI 2.3283064365386963e-10f
#define PCG6432_DOUBLE2_MULTI 2.3283064365386963e-10
#define PCG6432_DOUBLE_MULTI 5.4210108624275221700372640e-20

/**
State of pcg6432 RNG.
*/
typedef unsigned long pcg6432_state;

#define PCG6432_XORSHIFTED(s) ((uint)((((s) >> 18u) ^ (s)) >> 27u))
#define PCG6432_ROT(s) ((s) >> 59u)

#define pcg6432_macro_uint(state) ( \
	state = state * 6364136223846793005UL + 0xda3e39cb94b95bdbUL, \
	(PCG6432_XORSHIFTED(state) >> PCG6432_ROT(state)) | (PCG6432_XORSHIFTED(state) << ((-PCG6432_ROT(state)) & 31)) \
)

/**
Generates a random 32-bit unsigned integer using pcg6432 RNG.

@param state State of the RNG to use.
*/
#define pcg6432_uint(state) _pcg6432_uint(&state)
unsigned long _pcg6432_uint(pcg6432_state* state){
    ulong oldstate = *state;
	*state = oldstate * 6364136223846793005UL + 0xda3e39cb94b95bdbUL;
	uint xorshifted = ((oldstate >> 18u) ^ oldstate) >> 27u;
	uint rot = oldstate >> 59u;
	return (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
}

/**
Seeds pcg6432 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void pcg6432_seed(pcg6432_state* state, unsigned long j){
	*state=j;
}

/**
Generates a random 64-bit unsigned integer using pcg6432 RNG.

@param state State of the RNG to use.
*/
#define pcg6432_ulong(state) ((((ulong)pcg6432_uint(state)) << 32) | pcg6432_uint(state))

/**
Generates a random float using pcg6432 RNG.

@param state State of the RNG to use.
*/
#define pcg6432_float(state) (pcg6432_uint(state)*PCG6432_FLOAT_MULTI)

/**
Generates a random double using pcg6432 RNG.

@param state State of the RNG to use.
*/
#define pcg6432_double(state) (pcg6432_ulong(state)*PCG6432_DOUBLE_MULTI)

/**
Generates a random double using pcg6432 RNG. Generated using only 32 random bits.

@param state State of the RNG to use.
*/
#define pcg6432_double2(state) (pcg6432_uint(state)*PCG6432_DOUBLE2_MULTI)