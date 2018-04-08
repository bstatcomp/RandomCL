#pragma once

#define RNG32

#define LCG6432_FLOAT_MULTI 2.3283064365386963e-10f
#define LCG6432_DOUBLE2_MULTI 2.3283064365386963e-10
#define LCG6432_DOUBLE_MULTI 5.4210108624275221700372640e-20

typedef unsigned long lcg6432_state;

#define lcg6432_macro_uint(state) ( \
	state = state * 6364136223846793005UL + 0xda3e39cb94b95bdbUL, \
	state>>32 \
)
#define lcg6432_uint(state) _lcg6432_uint(&state)
	
unsigned long _lcg6432_uint(lcg6432_state* state){
	*state = *state * 6364136223846793005UL + 0xda3e39cb94b95bdbUL;
	return *state>>32;
}

void lcg6432_seed(lcg6432_state* state, unsigned long j){
	*state=j;
}

#define lcg6432_ulong(state) ((((ulong)lcg6432_uint(state)) << 32) | lcg6432_uint(state))
#define lcg6432_float(state) (lcg6432_uint(state)*LCG6432_FLOAT_MULTI)
#define lcg6432_double(state) (lcg6432_ulong(state)*LCG6432_DOUBLE_MULTI)
#define lcg6432_double2(state) (lcg6432_uint(state)*LCG6432_DOUBLE2_MULTI)