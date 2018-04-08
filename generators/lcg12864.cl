#pragma once

#define LCG12864_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define LCG12864_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define LCG12864_MULTI_HIGH 2549297995355413924UL
#define LCG12864_MULTI_LOW 4865540595714422341UL
#define LCG12864_INC_HIGH 6364136223846793005UL
#define LCG12864_INC_LOW 1442695040888963407UL

typedef struct{
	ulong low, high;
} lcg12864_state;

#define lcg12864_macro_ulong(state) ( \
	state.high = state.high * LCG12864_MULTI_LOW + state.low * LCG12864_MULTI_HIGH + mul_hi(state.low, LCG12864_MULTI_LOW), \
	state.low = state.low * LCG12864_MULTI_LOW, \
	state.low += LCG12864_INC_LOW, \
	state.high += state.low < LCG12864_INC_LOW, \
	state.high += LCG12864_INC_HIGH, \
	state.high \
)

#define lcg12864_ulong(state) _lcg12864_ulong(&state)
	
ulong _lcg12864_ulong(lcg12864_state* state){
	state->high = state->high * LCG12864_MULTI_LOW + state->low * LCG12864_MULTI_HIGH + mul_hi(state->low, LCG12864_MULTI_LOW);
	state->low = state->low * LCG12864_MULTI_LOW;

	state->low += LCG12864_INC_LOW;
	state->high += state->low < LCG12864_INC_LOW;
	state->high += LCG12864_INC_HIGH;
	return state->high;
}

void lcg12864_seed(lcg12864_state* state, ulong j){
	state->low=j;
	state->high=j^0xda3e39cb94b95bdbUL;
}

#define lcg12864_uint(state) ((uint)lcg12864_ulong(state))
#define lcg12864_float(state) (lcg12864_ulong(state)*LCG12864_FLOAT_MULTI)
#define lcg12864_double(state) (lcg12864_ulong(state)*LCG12864_DOUBLE_MULTI)
#define lcg12864_double2(state) lcg12864_double(state)