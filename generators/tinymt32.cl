/**
@file

Implements RandomCL interface to tinymt32 RNG.

Tiny mersenne twister, http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html.
*/
#pragma once

#define RNG32

#define TINYMT32_FLOAT_MULTI 2.3283064365386963e-10f
#define TINYMT32_DOUBLE2_MULTI 2.3283064365386963e-10
#define TINYMT32_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define KERNEL_PROGRAM
#include "TinyMT/tinymt32.clh"
#undef KERNEL_PROGRAM

/**
State of tinymt32 RNG.
*/
typedef tinymt32wp_t tinymt32_state;

/**
Generates a random 32-bit unsigned integer using tinymt32 RNG.

@param state State of the RNG to use.
*/
#define tinymt32_uint(state) tinymt32_uint32(&state)

//#define tinymt32_seed(state, seed) tinymt32_init(state, seed)


/**
Seeds tinymt32 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void tinymt32_seed(tinymt32_state* state, ulong seed){
	state->mat1=TINYMT32J_MAT1;
	state->mat2=TINYMT32J_MAT2;
	state->tmat=TINYMT32J_TMAT;
	tinymt32_init(state, seed);
}


/**
Generates a random 64-bit unsigned integer using tinymt32 RNG.

@param state State of the RNG to use.
*/
#define tinymt32_ulong(state) ((((ulong)tinymt32_uint(state)) << 32) | tinymt32_uint(state))

/**
Generates a random float using tinymt32 RNG.

@param state State of the RNG to use.
*/
#define tinymt32_float(state) (tinymt32_uint(state)*TINYMT32_FLOAT_MULTI)

/**
Generates a random double using tinymt32 RNG.

@param state State of the RNG to use.
*/
#define tinymt32_double(state) (tinymt32_ulong(state)*TINYMT32_DOUBLE_MULTI)

/**
Generates a random double using tinymt32 RNG. Generated using only 32 random bits.

@param state State of the RNG to use.
*/
#define tinymt32_double2(state) (tinymt32_uint(state)*TINYMT32_DOUBLE2_MULTI)