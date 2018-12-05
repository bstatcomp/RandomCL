/**
@file

Implements mrg31k3p RNG.

P. L’Ecuyer, R. Touzin, Fast combined multiple recursive generators with multipliers of the form a=+-2 q+-2 r, in: Proceedings of the 32nd conference on Winter simulation, Society for Computer Simulation International, 2000, pp. 683–689.
*/
#pragma once

#define RNG32

#define MRG31K3P_FLOAT_MULTI 4.6566128752457969230960e-10f
#define MRG31K3P_DOUBLE2_MULTI 4.6566128752457969230960e-10
#define MRG31K3P_DOUBLE_MULTI 2.1684043469904927853807e-19

#define MRG31K3P_M1 2147483647
#define MRG31K3P_M2 2147462579
#define MRG31K3P_MASK12 511
#define MRG31K3P_MASK13 16777215
#define MRG31K3P_MRG31K3P_MASK13 65535

/**
State of mrg31k3p RNG.
*/
typedef struct{
	uint x10, x11, x12, x20, x21, x22;
} mrg31k3p_state;

/**
Generates a random 32-bit unsigned integer using mrg31k3p RNG.

@param state State of the RNG to use.
*/
#define mrg31k3p_uint(state) _mrg31k3p_uint(&state)
uint _mrg31k3p_uint(mrg31k3p_state* state){
	uint y1, y2;
	//first component
	y1 = (((state->x11 & MRG31K3P_MASK12) << 22) + (state->x11 >> 9)) + (((state->x12 & MRG31K3P_MASK13) << 7) + (state->x12 >> 24));
	if (y1 > MRG31K3P_M1){ 
		y1 -= MRG31K3P_M1;
	}
	y1 += state->x12;
	if (y1 > MRG31K3P_M1){
		y1 -= MRG31K3P_M1;
	}
	state->x12 = state->x11;
	state->x11 = state->x10;
	state->x10 = y1;
	//second component
	y1 = ((state->x20 & MRG31K3P_MRG31K3P_MASK13) << 15) + 21069 * (state->x20 >> 16);
	if (y1 > MRG31K3P_M2){
		y1 -= MRG31K3P_M2;
	}
	y2 = ((state->x22 & MRG31K3P_MRG31K3P_MASK13) << 15) + 21069 * (state->x22 >> 16);
	if (y2 > MRG31K3P_M2){
		y2 -= MRG31K3P_M2;
	}
	y2 += state->x22;
	if (y2 > MRG31K3P_M2){
		y2 -= MRG31K3P_M2;
	}
	y2 += y1;
	if (y2 > MRG31K3P_M2){
		y2 -= MRG31K3P_M2;
	}
	state->x22 = state->x21;
	state->x21 = state->x20;
	state->x20 = y2;
	//combining the result
	if (state->x10 <= state->x20){
		return state->x10 - state->x20 + MRG31K3P_M1;
	}
	else{
		return state->x10 - state->x20;
	}
}

/**
Seeds mrg31k3p RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void mrg31k3p_seed(mrg31k3p_state* state, ulong j){
	state->x10 = j;
	state->x11 = j;
	state->x12 = j;
	state->x20 = j;
	state->x21 = j;
	state->x22 = j;
	if(j == 0){
		state->x10++;
		state->x21++;
	}
	if (state->x10 > MRG31K3P_M1) state->x10 -= MRG31K3P_M1;
	if (state->x11 > MRG31K3P_M1) state->x11 -= MRG31K3P_M1;
	if (state->x12 > MRG31K3P_M1) state->x12 -= MRG31K3P_M1;
	if (state->x20 > MRG31K3P_M2) state->x20 -= MRG31K3P_M2;
	if (state->x21 > MRG31K3P_M2) state->x21 -= MRG31K3P_M2;
	if (state->x22 > MRG31K3P_M2) state->x22 -= MRG31K3P_M2;
}

/**
Generates a random 64-bit unsigned integer using mrg31k3p RNG.

@param state State of the RNG to use.
*/
#define mrg31k3p_ulong(state) ((((ulong)mrg31k3p_uint(state)) << 32) | mrg31k3p_uint(state))

/**
Generates a random float using mrg31k3p RNG.

@param state State of the RNG to use.
*/
#define mrg31k3p_float(state) (mrg31k3p_uint(state)*MRG31K3P_FLOAT_MULTI)

/**
Generates a random double using mrg31k3p RNG.

@param state State of the RNG to use.
*/
#define mrg31k3p_double(state) (mrg31k3p_ulong(state)*MRG31K3P_DOUBLE2_MULTI + mrg31k3p_ulong(state)*MRG31K3P_DOUBLE_MULTI)

/**
Generates a random double using mrg31k3p RNG. Generated using only 32 random bits.

@param state State of the RNG to use.
*/
#define mrg31k3p_double2(state) (mrg31k3p_uint(state)*MRG31K3P_DOUBLE2_MULTI)