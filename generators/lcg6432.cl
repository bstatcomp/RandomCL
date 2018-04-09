/**
@file

Implements a 512-bit lcg6432 (Well-Equidistributed Long-period Linear) RNG. Not recomended for serious use, as it does not pass BigCrush test.
*/
#pragma once

#define RNG32

#define LCG6432_FLOAT_MULTI 2.3283064365386963e-10f
#define LCG6432_DOUBLE2_MULTI 2.3283064365386963e-10
#define LCG6432_DOUBLE_MULTI 5.4210108624275221700372640e-20

/**
State of lcg6432 RNG.
*/
typedef unsigned long lcg6432_state;

/**
Generates a random 32-bit unsigned integer using lcg6432 RNG.

This is alternative, macro implementation of lcg6432 RNG.

@param state State of the RNG to use.
*/
#define lcg6432_macro_uint(state) ( \
	state = state * 6364136223846793005UL + 0xda3e39cb94b95bdbUL, \
	state>>32 \
)

/**
Generates a random 32-bit unsigned integer using lcg6432 RNG.

@param state State of the RNG to use.
*/
#define lcg6432_uint(state) _lcg6432_uint(&state)
unsigned long _lcg6432_uint(lcg6432_state* state){
	*state = *state * 6364136223846793005UL + 0xda3e39cb94b95bdbUL;
	return *state>>32;
}

/**
Seeds lcg6432 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void lcg6432_seed(lcg6432_state* state, unsigned long j){
	*state=j;
}

/**
Generates a random 64-bit unsigned integer using lcg6432 RNG.

@param state State of the RNG to use.
*/
#define lcg6432_ulong(state) ((((ulong)lcg6432_uint(state)) << 32) | lcg6432_uint(state))

/**
Generates a random float using lcg6432 RNG.

@param state State of the RNG to use.
*/
#define lcg6432_float(state) (lcg6432_uint(state)*LCG6432_FLOAT_MULTI)

/**
Generates a random double using lcg6432 RNG.

@param state State of the RNG to use.
*/
#define lcg6432_double(state) (lcg6432_ulong(state)*LCG6432_DOUBLE_MULTI)

/**
Generates a random double using lcg6432 RNG. Generated using only 32 random bits.

@param state State of the RNG to use.
*/
#define lcg6432_double2(state) (lcg6432_uint(state)*LCG6432_DOUBLE2_MULTI)