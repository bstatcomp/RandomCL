#pragma once
#define RNG32

#define WELL512_FLOAT_MULTI 2.3283064365386963e-10f
#define WELL512_DOUBLE2_MULTI 2.3283064365386963e-10
#define WELL512_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define W 32
#define R 16
#define P 0
#define M1 13
#define M2 9
#define M3 5

typedef struct{
	unsigned int s[R];
	unsigned int i;
}well512_state;

#define MAT0POS(t,v) (v^(v>>t))
#define MAT0NEG(t,v) (v^(v<<(-(t))))
#define MAT3NEG(t,v) (v<<(-(t)))
#define MAT4NEG(t,b,v) (v ^ ((v<<(-(t))) & b))

#define V0_(state)            state.s[state.i                   ]
#define VM1_(state)           state.s[(state.i+M1) & 0x0000000fU]
#define VM2_(state)           state.s[(state.i+M2) & 0x0000000fU]
#define VM3_(state)           state.s[(state.i+M3) & 0x0000000fU]
#define VRm1_(state)          state.s[(state.i+15) & 0x0000000fU]
#define VRm2_(state)          state.s[(state.i+14) & 0x0000000fU]
#define newV0_(state)         state.s[(state.i+15) & 0x0000000fU]
#define newV1_(state)         state.s[state.i                   ]
#define newVRm1_(state)       state.s[(state.i+14) & 0x0000000fU]

#define WELL512MACRO_z0(state) VRm1_(state)
#define WELL512MACRO_z1(state) (MAT0NEG(-16,V0_(state)) ^ MAT0NEG(-15, VM1_(state)))
#define WELL512MACRO_z2(state) (MAT0POS(11, VM2_(state)))
#define well512_macro_uint(state) (\
	newV1_(state) = WELL512MACRO_z1(state) ^ WELL512MACRO_z2(state), \
	newV0_(state) = MAT0NEG(-2,WELL512MACRO_z0(state)) ^ MAT0NEG(-18,WELL512MACRO_z1(state)) ^ MAT3NEG(-28,WELL512MACRO_z2(state)) ^ MAT4NEG(-5,0xda442d24U,newV1_(state)), \
	state.i = (state.i + 15) & 0x0000000fU, \
	state.s[state.i] \
)

#define V0            state->s[state->i                   ]
#define VM1           state->s[(state->i+M1) & 0x0000000fU]
#define VM2           state->s[(state->i+M2) & 0x0000000fU]
#define VM3           state->s[(state->i+M3) & 0x0000000fU]
#define VRm1          state->s[(state->i+15) & 0x0000000fU]
#define VRm2          state->s[(state->i+14) & 0x0000000fU]
#define newV0         state->s[(state->i+15) & 0x0000000fU]
#define newV1         state->s[state->i                   ]
#define newVRm1       state->s[(state->i+14) & 0x0000000fU]

#define well512_uint(state) _well512_uint(&state)

uint _well512_uint(well512_state* state){
	unsigned int z0, z1, z2;
	z0    = VRm1;
	z1    = MAT0NEG (-16,V0)    ^ MAT0NEG (-15, VM1);
	z2    = MAT0POS (11, VM2)  ;
	newV1 = z1                  ^ z2; 
	newV0 = MAT0NEG (-2,z0)     ^ MAT0NEG(-18,z1)    ^ MAT3NEG(-28,z2) ^ MAT4NEG(-5,0xda442d24U,newV1) ;
	state->i = (state->i + 15) & 0x0000000fU;
	return state->s[state->i];
}

/*
double well512_double(well512_state* state){
	return ((double) well512_uint(state)) * WELL512_DOUBLE_MULTI;
}
*/

void well512_seed(well512_state* state, unsigned long j){
    state->i = 0;
    for (int i = 0; i < R; i+=2){
		j=6906969069UL * j + 1234567UL; //LCG
		state->s[i    ] = j;
		state->s[i + 1] = j>>32;
	}
}

#define well512_ulong(state) ((((ulong)well512_uint(state)) << 32) | well512_uint(state))
#define well512_float(state) (well512_uint(state)*WELL512_FLOAT_MULTI)
#define well512_double(state) (well512_ulong(state)*WELL512_DOUBLE_MULTI)
#define well512_double2(state) (well512_uint(state)*WELL512_DOUBLE2_MULTI)