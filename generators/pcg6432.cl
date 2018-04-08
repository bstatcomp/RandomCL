#pragma once

#define RNG32

#define PCG6432_FLOAT_MULTI 2.3283064365386963e-10f
#define PCG6432_DOUBLE2_MULTI 2.3283064365386963e-10
#define PCG6432_DOUBLE_MULTI 5.4210108624275221700372640e-20

typedef unsigned long pcg6432_state;

#define PCG6432_XORSHIFTED(s) ((uint)((((s) >> 18u) ^ (s)) >> 27u))
#define PCG6432_ROT(s) ((s) >> 59u)

#define pcg6432_macro_uint(state) ( \
	state = state * 6364136223846793005UL + 0xda3e39cb94b95bdbUL, \
	(PCG6432_XORSHIFTED(state) >> PCG6432_ROT(state)) | (PCG6432_XORSHIFTED(state) << ((-PCG6432_ROT(state)) & 31)) \
)

#define pcg6432_uint(state) _pcg6432_uint(&state)

unsigned long _pcg6432_uint(pcg6432_state* state){
    ulong oldstate = *state;
	*state = oldstate * 6364136223846793005UL + 0xda3e39cb94b95bdbUL;
	uint xorshifted = ((oldstate >> 18u) ^ oldstate) >> 27u;
	uint rot = oldstate >> 59u;
	return (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
}

void pcg6432_seed(pcg6432_state* state, unsigned long j){
	*state=j;
}

#define pcg6432_ulong(state) ((((ulong)pcg6432_uint(state)) << 32) | pcg6432_uint(state))
#define pcg6432_float(state) (pcg6432_uint(state)*PCG6432_FLOAT_MULTI)
#define pcg6432_double(state) (pcg6432_ulong(state)*PCG6432_DOUBLE_MULTI)
#define pcg6432_double2(state) (pcg6432_uint(state)*PCG6432_DOUBLE2_MULTI)