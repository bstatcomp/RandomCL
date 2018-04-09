/**
@file

Implements RandomCL interface to tinymt64 RNG.
*/
#pragma once

#define TINYMT64_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define TINYMT64_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define KERNEL_PROGRAM
#include "TinyMT/tinymt64.clh"
#undef KERNEL_PROGRAM

/**
State of tinymt64 RNG.
*/
typedef tinymt64wp_t tinymt64_state;


/**
Generates a random 64-bit unsigned integer using tinymt64 RNG.

@param state State of the RNG to use.
*/
#define tinymt64_ulong(state) tinymt64_uint64(&state)

//#define tinymt64_seed(state, seed) tinymt64_init(state, seed)

/**
Seeds tinymt64 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void tinymt64_seed(tinymt64_state* state, ulong seed){
	state->mat1=TINYMT64J_MAT1;
	state->mat2=TINYMT64J_MAT2;
	state->tmat=TINYMT64J_TMAT;
	tinymt64_init(state, seed);
}

/**
Generates a random 32-bit unsigned integer using tinymt64 RNG.

@param state State of the RNG to use.
*/
#define tinymt64_uint(state) ((uint)tinymt64_ulong(state))

/**
Generates a random float using tinymt64 RNG.

@param state State of the RNG to use.
*/
#define tinymt64_float(state) (tinymt64_ulong(state)*TINYMT64_FLOAT_MULTI)

/**
Generates a random double using tinymt64 RNG.

@param state State of the RNG to use.
*/
#define tinymt64_double(state) (tinymt64_ulong(state)*TINYMT64_DOUBLE_MULTI)

/**
Generates a random double using tinymt64 RNG. Since tinymt64 returns 64-bit numbers this is equivalent to tinymt64_double.

@param state State of the RNG to use.
*/
#define tinymt64_double2(state) tinymt64_double(state)