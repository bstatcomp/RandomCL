#pragma once
#define RNG32

#define KISS99_FLOAT_MULTI 2.3283064365386963e-10f
#define KISS99_DOUBLE2_MULTI 2.3283064365386963e-10
#define KISS99_DOUBLE_MULTI 5.4210108624275221700372640e-20

//http://www.cse.yorku.ca/~oz/marsaglia-rng.html
typedef struct {
	uint z, w, jsr, jcong;
} kiss99_state;

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

#define kiss99_ulong(state) ((((ulong)kiss99_uint(state)) << 32) | kiss99_uint(state))
#define kiss99_float(state) (kiss99_uint(state)*KISS99_FLOAT_MULTI)
#define kiss99_double(state) (kiss99_ulong(state)*KISS99_DOUBLE_MULTI)
#define kiss99_double2(state) (kiss99_uint(state)*KISS99_DOUBLE2_MULTI)