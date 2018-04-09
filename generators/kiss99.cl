/**
@file

Implements KISS (Keep It Simple, Stupid) generator, proposed in 1999.
*/
#pragma once
#define RNG32

#define KISS99_FLOAT_MULTI 2.3283064365386963e-10f
#define KISS99_DOUBLE2_MULTI 2.3283064365386963e-10
#define KISS99_DOUBLE_MULTI 5.4210108624275221700372640e-20

//http://www.cse.yorku.ca/~oz/marsaglia-rng.html

/**
State of kiss99 RNG.
*/
typedef struct {
	uint z, w, jsr, jcong;
} kiss99_state;

/**
Generates a random 32-bit unsigned integer using kiss99 RNG.

This is alternative, macro implementation of kiss99 RNG.

@param state State of the RNG to use.
*/
#define kiss99_macro_uint(state) (\
	/*multiply with carry*/ \
	state.z = 36969 * (state.z & 65535) + (state.z >> 16), \
	state.w = 18000 * (state.w & 65535) + (state.w >> 16), \
	/*xorshift*/ \
	state.jsr ^= state.jsr << 17, \
	state.jsr ^= state.jsr >> 13, \
	state.jsr ^= state.jsr << 5, \
	/*linear congruential*/ \
	state.jcong = 69069 * state.jcong + 1234567, \
	\
	(((state.z << 16) + state.w) ^ state.jcong) + state.jsr \
	)
	
/**
Generates a random 32-bit unsigned integer using kiss99 RNG.

@param state State of the RNG to use.
*/
#define kiss99_uint(state) _kiss99_uint(&state)
uint _kiss99_uint(kiss99_state* state){
	//multiply with carry
	state->z = 36969 * (state->z & 65535) + (state->z >> 16);
	state->w = 18000 * (state->w & 65535) + (state->w >> 16);
	
	//xorshift
	state->jsr ^= state->jsr << 17;
	state->jsr ^= state->jsr >> 13;
	state->jsr ^= state->jsr << 5;
	
	//linear congruential
	state->jcong = 69069 * state->jcong + 1234567;
	
	return (((state->z << 16) + state->w) ^ state->jcong) + state->jsr;
}

/**
Seeds kiss99 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void kiss99_seed(kiss99_state* state, ulong j){
	state->z=362436069 ^ (uint)j;
	if(state->z==0){
		state->z=1;
	}
	state->w=521288629 ^ (uint)(j >> 32);
	if(state->w==0){
		state->w=1;
	}
	state->jsr=123456789 ^ (uint)j;
	if(state->jsr==0){
		state->jsr=1;
	}
	state->jcong=380116160 ^ (uint)(j >> 32);
}

/**
Generates a random 64-bit unsigned integer using kiss99 RNG.

@param state State of the RNG to use.
*/
#define kiss99_ulong(state) ((((ulong)kiss99_uint(state)) << 32) | kiss99_uint(state))

/**
Generates a random float using kiss99 RNG.

@param state State of the RNG to use.
*/
#define kiss99_float(state) (kiss99_uint(state)*KISS99_FLOAT_MULTI)

/**
Generates a random double using kiss99 RNG.

@param state State of the RNG to use.
*/
#define kiss99_double(state) (kiss99_ulong(state)*KISS99_DOUBLE_MULTI)

/**
Generates a random double using kiss99 RNG. Generated using only 32 random bits.

@param state State of the RNG to use.
*/
#define kiss99_double2(state) (kiss99_uint(state)*KISS99_DOUBLE2_MULTI)