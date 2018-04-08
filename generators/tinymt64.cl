#pragma once

#define TINYMT64_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define TINYMT64_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define KERNEL_PROGRAM
#include "TinyMT/tinymt64.clh"
#undef KERNEL_PROGRAM

typedef tinymt64wp_t tinymt64_state;

#define tinymt64_ulong(state) tinymt64_uint64(&state)

//#define tinymt64_seed(state, seed) tinymt64_init(state, seed)

void tinymt64_seed(tinymt64_state* state, ulong seed){
	state->mat1=TINYMT64J_MAT1;
	state->mat2=TINYMT64J_MAT2;
	state->tmat=TINYMT64J_TMAT;
	tinymt64_init(state, seed);
}

#define tinymt64_uint(state) ((uint)tinymt64_ulong(state))
#define tinymt64_float(state) (tinymt64_ulong(state)*TINYMT64_FLOAT_MULTI)
#define tinymt64_double(state) (tinymt64_ulong(state)*TINYMT64_DOUBLE_MULTI)
#define tinymt64_double2(state) tinymt64_double(state)