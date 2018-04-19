/**
@file

Implements philox2x32-10 RNG.

J. K. Salmon, M. A. Moraes, R. O. Dror, D. E. Shaw, Parallel random numbers: as easy as 1, 2, 3, in: High Performance Computing, Networking, Storage and Analysis (SC), 2011 International Conference for, IEEE, 2011, pp. 1–12.
*/
#pragma once

#define PHILOX2X32_10_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define PHILOX2X32_10_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define PHILOX2X32_10_MULTIPLIER 0xd256d193
#define PHILOX2X32_10_KEY_INC 0x9E3779B9
//#define PHILOX2X64_10_MULTIPLIER 0xD2B74407B1CE6E93
//#define PHILOX2X64_10_KEY_INC 0x9E3779B97F4A7C15 //golden ratio

/**
State of philox2x32_10 RNG.
*/
typedef union{
	ulong LR;
	struct{
		uint L, R;
	};
} philox2x32_10_state;

/**
Internal function. calculates philox2x32-10 random number from state and key.

@param state State of the RNG to use.
@param key Key to use.
*/
ulong philox2x32_10(philox2x32_10_state state, uint key){
	uint tmp, L = state.L, R = state.R;
	for(uint i=0;i<10;i++){
		uint tmp = R * PHILOX2X32_10_MULTIPLIER;
		R = mul_hi(R,PHILOX2X32_10_MULTIPLIER) ^ L ^ key;
		L = tmp;
		key += PHILOX2X32_10_KEY_INC;
	}
	state.L = L;
	state.R = R;
	return state.LR;
}

/**
Generates a random 64-bit unsigned integer using philox2x32_10 RNG.

@param state State of the RNG to use.
*/
#define philox2x32_10_ulong(state) _philox2x32_10_ulong(&state)
ulong _philox2x32_10_ulong(philox2x32_10_state *state){
	state->LR++;
	return philox2x32_10(*state, 12345);
}

/**
Seeds philox2x32_10 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void philox2x32_10_seed(philox2x32_10_state *state, ulong j){
	state->LR = j;
}

/**
Generates a random 32-bit unsigned integer using philox2x32_10 RNG.

@param state State of the RNG to use.
*/
#define philox2x32_10_uint(state) ((uint)philox2x32_10_ulong(state))

/**
Generates a random float using philox2x32_10 RNG.

@param state State of the RNG to use.
*/
#define philox2x32_10_float(state) (philox2x32_10_ulong(state)*PHILOX2X32_10_FLOAT_MULTI)

/**
Generates a random double using philox2x32_10 RNG.

@param state State of the RNG to use.
*/
#define philox2x32_10_double(state) (philox2x32_10_ulong(state)*PHILOX2X32_10_DOUBLE_MULTI)

/**
Generates a random double using philox2x32_10 RNG. Since philox2x32_10 returns 64-bit numbers this is equivalent to philox2x32_10_double.

@param state State of the RNG to use.
*/
#define philox2x32_10_double2(state) philox2x32_10_double(state)