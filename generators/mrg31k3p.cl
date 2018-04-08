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

typedef struct{
	ulong x10, x11, x12, x20, x21, x22;
} mrg31k3p_state;

//different macro implementation does not make sense - RNG requires local variables
#define mrg31k3p_uint(state) _mrg31k3p_uint(&state)

uint _mrg31k3p_uint(mrg31k3p_state* state){
	ulong y1, y2;
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

float mrg31k3p_float(mrg31k3p_state* state){
	return _mrg31k3p_uint(state) * MRG31K3P_FLOAT_MULTI;
}

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

#define mrg31k3p_ulong(state) ((((ulong)mrg31k3p_uint(state)) << 32) | mrg31k3p_uint(state))
#define mrg31k3p_float(state) (mrg31k3p_uint(state)*MRG31K3P_FLOAT_MULTI)
#define mrg31k3p_double(state) (mrg31k3p_ulong(state)*MRG31K3P_DOUBLE2_MULTI + mrg31k3p_ulong(state)*MRG31K3P_DOUBLE_MULTI)
#define mrg31k3p_double2(state) (mrg31k3p_uint(state)*MRG31K3P_DOUBLE2_MULTI)