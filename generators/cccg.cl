#pragma once

typedef union {
	struct{
		unsigned short y1,y2,y3,y4;
	};
	unsigned long val;
}cccg_state;

#define cccg_ulong(state) ( \
	state.y1 = ( 4535u * state.y1 * state.y1 * state.y1 + 1) % 32687u, \
	state.y2 = ( 1190u * state.y2 * state.y2 * state.y2 + 1) % 32693u, \
	state.y3 = (10077u * state.y3 * state.y3 * state.y3 + 1) % 32633u, \
	state.y4 = (21835u * state.y4 * state.y4 * state.y4 + 1) % 32621u, \
	state.val \
	)
	
	
unsigned long _cccg_ulong(cccg_state* state){
	state->y1 = ( 4535u * state->y1 * state->y1 * state->y1 + 1) % 32687u;
	state->y2 = ( 1190u * state->y2 * state->y2 * state->y2 + 1) % 32693u;
	state->y3 = (10077u * state->y3 * state->y3 * state->y3 + 1) % 32633u;
	state->y4 = (21835u * state->y4 * state->y4 * state->y4 + 1) % 32621u;
	return state->val;
}

float _cccg_float(cccg_state* state){
	_cccg_ulong(state);
	float res = 
		state->y1 * 3.059320219047328e-05f +
		state->y2 * 3.0587587556969384e-05f +
		state->y3 * 3.064382680109092e-05f +
		state->y4 * 3.06550994757978e-05f;
	while(res>1.0f){
		res-=1.0;
	}
	return res;
}

void cccg_seed(cccg_state* state, unsigned long j){
	state->val=j;
}