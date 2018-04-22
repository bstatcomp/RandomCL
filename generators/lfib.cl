/**
@file

Implements a Multiplicative Lagged Fibbonaci generator. Returns 64-bit random numbers, but the lowest bit is always 1.

G. Marsaglia, L.-H. Tsay, Matrices and the structure of random number sequences, Linear algebra and its applications 67 (1985) 147–156.
*/
#pragma once

#define LFIB_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define LFIB_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define LFIB_LAG1 17
#define LFIB_LAG2 5

/**
State of lfib RNG.
*/
typedef struct{
	ulong s[LFIB_LAG1];
	char p1,p2;
}lfib_state;
	
/**
Generates a random 64-bit unsigned integer using lfib RNG.

This is alternative, macro implementation of lfib RNG.

@param state State of the RNG to use.
*/
#define lfib_macro_ulong(state) ( \
	state.p1 = --state.p1 >= 0 ? state.p1 : LFIB_LAG1 - 1, \
	state.p2 = --state.p2 >= 0 ? state.p2 : LFIB_LAG1 - 1, \
	state.s[state.p1]*=state.s[state.p2], \
	state.s[state.p1] \
)

/**
Generates a random 64-bit unsigned integer using lfib RNG.

@param state State of the RNG to use.
*/
#define lfib_ulong(state) _lfib_ulong(&state)
ulong _lfib_ulong(lfib_state* state){
	/*state->p1++;
	state->p1%=LFIB_LAG1;
	state->p2++;
	state->p2%=LFIB_LAG2;*/
	state->p1 = --state->p1 >= 0 ? state->p1 : LFIB_LAG1 - 1;
	state->p2 = --state->p2 >= 0 ? state->p2 : LFIB_LAG1 - 1;
	state->s[state->p1] *= state->s[state->p2];
	return state->s[state->p1];
}

/**
Generates a random 64-bit unsigned integer using lfib RNG.

This is alternative implementation of lfib RNG using if statements instead of ternary operators.

@param state State of the RNG to use.
*/
#define lfib_ifs_ulong(state) _lfib_ifs_ulong(&state)
ulong _lfib_ifs_ulong(lfib_state* state){
	/*state->p1++;
	state->p1%=LFIB_LAG1;
	state->p2++;
	state->p2%=LFIB_LAG2;*/
	state->p1--;
	if(state->p1<0) state->p1=LFIB_LAG1-1;
	state->p2--;
	if(state->p2<0) state->p2=LFIB_LAG1-1;
	state->s[state->p1]*=state->s[state->p2];
	return state->s[state->p1];
}

/**
Generates a random 64-bit unsigned integer using lfib RNG.

This is alternative implementation of lfib RNG using modulo instead of conditionals.

@param state State of the RNG to use.
*/
#define lfib_inc_ulong(state) _lfib_inc_ulong(&state)
ulong _lfib_inc_ulong(lfib_state* state){
	state->p1++;
	state->p1%=LFIB_LAG1;
	state->p2++;
	state->p2%=LFIB_LAG2;
	state->s[state->p1]*=state->s[state->p2];
	return state->s[state->p1];
}
/**
Generates a random 64-bit unsigned integer using lfib RNG.

This is alternative, macro implementation of lfib RNG using modulo instead of conditionals.

@param state State of the RNG to use.
*/
#define lfib_inc_macro_ulong(state) ( \
	state.p1++, \
	state.p1%=LFIB_LAG1, \
	state.p2++, \
	state.p2%=LFIB_LAG2, \
	state.s[state.p1]*=state.s[state.p2], \
	state.s[state.p1] \
)

/**
Seeds lfib RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void lfib_seed(lfib_state* state, ulong j){
	state->p1=LFIB_LAG1;
	state->p2=LFIB_LAG2;
	//if(get_global_id(0)==0) printf("seed %d\n",state->p1);
    for (int i = 0; i < LFIB_LAG1; i++){
		j=6906969069UL * j + 1234567UL; //LCG
		state->s[i] = j | 1; // values must be odd
	}
}

/**
Generates a random 32-bit unsigned integer using lfib RNG.

@param state State of the RNG to use.
*/
#define lfib_uint(state) ((uint)(lfib_ulong(state)>>1))

/**
Generates a random float using lfib RNG.

@param state State of the RNG to use.
*/
#define lfib_float(state) (lfib_ulong(state)*LFIB_FLOAT_MULTI)

/**
Generates a random double using lfib RNG.

@param state State of the RNG to use.
*/
#define lfib_double(state) (lfib_ulong(state)*LFIB_DOUBLE_MULTI)

/**
Generates a random double using lfib RNG. Since lfib returns 64-bit numbers this is equivalent to lfib_double.

@param state State of the RNG to use.
*/
#define lfib_double2(state) lfib_double(state)