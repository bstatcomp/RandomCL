/**
@file

Implements a 128-bit Linear Congruential Generator. Returns 64-bit numbers.

P. L’ecuyer, Tables of linear congruential generators of different sizes and good lattice structure, Mathematics of Computation of the American Mathematical Society 68 (225) (1999) 249–260.
*/
#pragma once

#define LCG12864_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define LCG12864_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define LCG12864_MULTI_HIGH 2549297995355413924UL
#define LCG12864_MULTI_LOW 4865540595714422341UL
#define LCG12864_INC_HIGH 6364136223846793005UL
#define LCG12864_INC_LOW 1442695040888963407UL

/**
State of lcg12864 RNG.
*/
typedef struct{
	ulong low, high;
} lcg12864_state;

/**
Generates a random 64-bit unsigned integer using lcg12864 RNG.

This is alternative, macro implementation of lcg12864 RNG.

@param state State of the RNG to use.
*/
#define lcg12864_macro_ulong(state) ( \
	state.high = state.high * LCG12864_MULTI_LOW + state.low * LCG12864_MULTI_HIGH + mul_hi(state.low, LCG12864_MULTI_LOW), \
	state.low = state.low * LCG12864_MULTI_LOW, \
	state.low += LCG12864_INC_LOW, \
	state.high += state.low < LCG12864_INC_LOW, \
	state.high += LCG12864_INC_HIGH, \
	state.high \
)

/**
Generates a random 64-bit unsigned integer using lcg12864 RNG.

@param state State of the RNG to use.
*/
#define lcg12864_ulong(state) _lcg12864_ulong(&state)
ulong _lcg12864_ulong(lcg12864_state* state){
	state->high = state->high * LCG12864_MULTI_LOW + state->low * LCG12864_MULTI_HIGH + mul_hi(state->low, LCG12864_MULTI_LOW);
	state->low = state->low * LCG12864_MULTI_LOW;

	state->low += LCG12864_INC_LOW;
	state->high += state->low < LCG12864_INC_LOW;
	state->high += LCG12864_INC_HIGH;
	return state->high;
}

/**
Seeds lcg12864 RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void lcg12864_seed(lcg12864_state* state, ulong j){
	state->low=j;
	state->high=j^0xda3e39cb94b95bdbUL;
}

/**
Generates a random 32-bit unsigned integer using lcg12864 RNG.

@param state State of the RNG to use.
*/
#define lcg12864_uint(state) ((uint)lcg12864_ulong(state))

/**
Generates a random float using lcg12864 RNG.

@param state State of the RNG to use.
*/
#define lcg12864_float(state) (lcg12864_ulong(state)*LCG12864_FLOAT_MULTI)

/**
Generates a random double using lcg12864 RNG.

@param state State of the RNG to use.
*/
#define lcg12864_double(state) (lcg12864_ulong(state)*LCG12864_DOUBLE_MULTI)

/**
Generates a random double using lcg12864 RNG. Since lcg12864 returns 64-bit numbers this is equivalent to lcg12864_double.

@param state State of the RNG to use.
*/
#define lcg12864_double2(state) lcg12864_double(state)