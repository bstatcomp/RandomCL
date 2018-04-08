#pragma once

#define PHILOX2X32_10_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define PHILOX2X32_10_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define PHILOX2X32_10_MULTIPLIER 0xd256d193
#define PHILOX2X32_10_KEY_INC 0x9E3779B9
//#define PHILOX2X64_10_MULTIPLIER 0xD2B74407B1CE6E93
//#define PHILOX2X64_10_KEY_INC 0x9E3779B97F4A7C15 //golden ratio

typedef union{
	ulong LR;
	struct{
		uint L, R;
	};
} philox2x32_10_state;

ulong philox2x32_10(philox2x32_10_state state, uint key){
	uint tmp, L = state.L, R = state.R;
	for(uint i=0;i<10;i++){
		uint tmp = R * PHILOX2X32_10_MULTIPLIER;
		R = mul_hi(R,PHILOX2X32_10_MULTIPLIER) ^ L ^ key;
		L = tmp;
		key += PHILOX2X32_10_KEY_INC;
	}
	state.L = L;
	state.R = R;
	return state.LR;
}

#define philox2x32_10_ulong(state) _philox2x32_10_ulong(&state)

ulong _philox2x32_10_ulong(philox2x32_10_state *state){
	state->LR++;
	return philox2x32_10(*state, get_global_id(0));
}

void philox2x32_10_seed(philox2x32_10_state *state, ulong j){
	state->LR = j;
}

#define philox2x32_10_uint(state) ((uint)philox2x32_10_ulong(state))
#define philox2x32_10_float(state) (philox2x32_10_ulong(state)*PHILOX2X32_10_FLOAT_MULTI)
#define philox2x32_10_double(state) (philox2x32_10_ulong(state)*PHILOX2X32_10_DOUBLE_MULTI)
#define philox2x32_10_double2(state) philox2x32_10_double(state)