#pragma once

#define LFIB_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define LFIB_DOUBLE_MULTI 5.4210108624275221700372640e-20

//http://www.sprng.org/Version5.0/parameters.html
//Marsaglia: Matrices and the Structure of Random Number Sequences
#define LFIB_LAG1 17
#define LFIB_LAG2 5

typedef struct{
	ulong s[LFIB_LAG1];
	int p1,p2;
}lfib_state;
	
#define lfib_macro_ulong(state) ( \
	state.p1 = --state.p1 >= 0 ? state.p1 : LFIB_LAG1 - 1, \
	state.p2 = --state.p2 >= 0 ? state.p2 : LFIB_LAG1 - 1, \
	state.s[state.p1]*=state.s[state.p2], \
	state.s[state.p1] \
)

#define lfib_ulong(state) _lfib_ulong(&state)

ulong _lfib_ulong(lfib_state* state){
	/*state->p1++;
	state->p1%=LFIB_LAG1;
	state->p2++;
	state->p2%=LFIB_LAG2;*/
	state->p1 = --state->p1 >= 0 ? state->p1 : LFIB_LAG1 - 1;
	state->p2 = --state->p2 >= 0 ? state->p2 : LFIB_LAG1 - 1;
	state->s[state->p1]*=state->s[state->p2];
	return state->s[state->p1];
}

#define lfib_ifs_ulong(state) _lfib_ifs_ulong(&state)
ulong _lfib_ifs_ulong(lfib_state* state){
	/*state->p1++;
	state->p1%=LFIB_LAG1;
	state->p2++;
	state->p2%=LFIB_LAG2;*/
	state->p1--;
	if(state->p1<0) state->p1=LFIB_LAG1-1;
	state->p2--;
	if(state->p2<0) state->p2=LFIB_LAG1-1;
	state->s[state->p1]*=state->s[state->p2];
	return state->s[state->p1];
}

#define lfib_inc_ulong(state) _lfib_inc_ulong(&state)
ulong _lfib_inc_ulong(lfib_state* state){
	state->p1++;
	state->p1%=LFIB_LAG1;
	state->p2++;
	state->p2%=LFIB_LAG2;
	state->s[state->p1]*=state->s[state->p2];
	return state->s[state->p1];
}

#define lfib_inc_macro_ulong(state) ( \
	state.p1++, \
	state.p1%=LFIB_LAG1, \
	state.p2++, \
	state.p2%=LFIB_LAG2, \
	state.s[state.p1]*=state.s[state.p2], \
	state.s[state.p1] \
)

void lfib_seed(lfib_state* state, ulong j){
	state->p1=LFIB_LAG1;
	state->p2=LFIB_LAG2;
	//if(get_global_id(0)==0) printf("seed %d\n",state->p1);
    for (int i = 0; i < LFIB_LAG1; i++){
		j=6906969069UL * j + 1234567UL; //LCG
		state->s[i] = j | 1; // values must be odd
	}
}

#define lfib_uint(state) ((uint)(lfib_ulong(state)>>1))
#define lfib_float(state) (lfib_ulong(state)*LFIB_FLOAT_MULTI)
#define lfib_double(state) (lfib_ulong(state)*LFIB_DOUBLE_MULTI)
#define lfib_double2(state) lfib_double(state)