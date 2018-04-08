#pragma once

#define KISS09_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define KISS09_DOUBLE_MULTI 5.4210108624275221700372640e-20

//https://www.thecodingforums.com/threads/64-bit-kiss-rngs.673657/
typedef struct {
	ulong x,c,y,z;
} kiss09_state;

#define kiss09_macro_ulong(state) (\
	/*multiply with carry*/ \
	state.c = state.x >> 6, \
	state.x += (state.x << 58) + state.c, \
	state.c += state.x < (state.x << 58) + state.c, \
	/*xorshift*/ \
	state.y ^= state.y << 13, \
	state.y ^= state.y >> 17, \
	state.y ^= state.y << 43, \
	/*linear congruential*/ \
	state.z = 6906969069UL * state.z + 1234567UL, \
	state.x + state.y + state.z \
	)

#define kiss09_ulong(state) _kiss09_ulong(&state)
	
ulong _kiss09_ulong(kiss09_state* state){
	//multiply with carry
	ulong t = (state->x << 58) + state->c;
	state->c = state-> x >>6;
	state->x += t;
	state->c += state->x < t;
	//xorshift
	state->y ^= state->y << 13;
	state->y ^= state->y >> 17;
	state->y ^= state->y << 43;
	//linear congruential
	state->z = 6906969069UL * state->z + 1234567UL;
	return state->x + state->y + state->z;
}

void kiss09_seed(kiss09_state* state, ulong j){
	state->x = 1234567890987654321UL ^ j;
	state->c = 123456123456123456UL ^ j;
	state->y = 362436362436362436UL ^ j;
	if(state->y==0){
		state->y=1;
	}
	state->z = 1066149217761810UL ^ j;
}

#define kiss09_uint(state) ((uint)kiss09_ulong(state))
#define kiss09_float(state) (kiss09_ulong(state)*KISS09_FLOAT_MULTI)
#define kiss09_double(state) (kiss09_ulong(state)*KISS09_DOUBLE_MULTI)
#define kiss09_double2(state) kiss09_double(state)