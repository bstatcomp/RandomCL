#pragma once
#define RNG32

#define XORSHIFT6432STAR_FLOAT_MULTI 2.3283064365386963e-10f
#define XORSHIFT6432STAR_DOUBLE2_MULTI 2.3283064365386963e-10
#define XORSHIFT6432STAR_DOUBLE_MULTI 5.4210108624275221700372640e-20

typedef unsigned long xorshift6432star_state;

#define xorshift6432star_macro_uint(state) (\
	state ^= state >> 12, \
	state ^= state << 25, \
	state ^= state >> 27, \
	(uint)((state*0x2545F4914F6CDD1D)>>32) \
	)
	
#define xorshift6432star_uint(state) _xorshift6432star_uint(&state)
	
unsigned int _xorshift6432star_uint(xorshift6432star_state* restrict state){
	*state ^= *state >> 12; // a
	*state ^= *state << 25; // b
	*state ^= *state >> 27; // c
	return (uint)((*state*0x2545F4914F6CDD1D)>>32);
}

void xorshift6432star_seed(xorshift6432star_state* state, unsigned long j){
	if(j==0){
		j++;
	}
	*state=j;
}

#define xorshift6432star_ulong(state) ((((ulong)xorshift6432star_uint(state)) << 32) | xorshift6432star_uint(state))
#define xorshift6432star_float(state) (xorshift6432star_uint(state)*XORSHIFT6432STAR_FLOAT_MULTI)
#define xorshift6432star_double(state) (xorshift6432star_ulong(state)*XORSHIFT6432STAR_DOUBLE_MULTI)
#define xorshift6432star_double2(state) (xorshift6432star_uint(state)*XORSHIFT6432STAR_DOUBLE2_MULTI)