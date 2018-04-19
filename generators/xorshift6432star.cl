/**
@file

Implements a 64-bit xorshift* generator that returns 32-bit values.

S. Vigna, An experimental exploration of marsaglia’s xorshift generators, scrambled, ACM Transactions on Mathematical Software (TOMS) 42 (4) (2016) 30.
*/
#pragma once
#define RNG32

#define XORSHIFT6432STAR_FLOAT_MULTI 2.3283064365386963e-10f
#define XORSHIFT6432STAR_DOUBLE2_MULTI 2.3283064365386963e-10
#define XORSHIFT6432STAR_DOUBLE_MULTI 5.4210108624275221700372640e-20

/**
State of xorshift6432star RNG.
*/
typedef unsigned long xorshift6432star_state;

#define xorshift6432star_macro_uint(state) (\
	state ^= state >> 12, \
	state ^= state << 25, \
	state ^= state >> 27, \
	(uint)((state*0x2545F4914F6CDD1D)>>32) \
	)

/**
Generates a random 32-bit unsigned integer using xorshift6432star RNG.

@param state State of the RNG to use.
*/
#define xorshift6432star_uint(state) _xorshift6432star_uint(&state)
unsigned int _xorshift6432star_uint(xorshift6432star_state* restrict state){
	*state ^= *state >> 12; // a
	*state ^= *state << 25; // b
	*state ^= *state >> 27; // c
	return (uint)((*state*0x2545F4914F6CDD1D)>>32);
}

/**
Seeds xorshift6432star RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void xorshift6432star_seed(xorshift6432star_state* state, unsigned long j){
	if(j==0){
		j++;
	}
	*state=j;
}

/**
Generates a random 64-bit unsigned integer using xorshift6432star RNG.

@param state State of the RNG to use.
*/
#define xorshift6432star_ulong(state) ((((ulong)xorshift6432star_uint(state)) << 32) | xorshift6432star_uint(state))

/**
Generates a random float using xorshift6432star RNG.

@param state State of the RNG to use.
*/
#define xorshift6432star_float(state) (xorshift6432star_uint(state)*XORSHIFT6432STAR_FLOAT_MULTI)

/**
Generates a random double using xorshift6432star RNG.

@param state State of the RNG to use.
*/
#define xorshift6432star_double(state) (xorshift6432star_ulong(state)*XORSHIFT6432STAR_DOUBLE_MULTI)

/**
Generates a random double using xorshift6432star RNG. Generated using only 32 random bits.

@param state State of the RNG to use.
*/
#define xorshift6432star_double2(state) (xorshift6432star_uint(state)*XORSHIFT6432STAR_DOUBLE2_MULTI)