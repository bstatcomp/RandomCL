/* ind(mm,x) is bits 2..9 of x, or (floor(x/4) mod 256)*4 */
#pragma once

#define RNG32

#define ISAAC_FLOAT_MULTI 2.3283064365386963e-10f
#define ISAAC_DOUBLE2_MULTI 2.3283064365386963e-10
#define ISAAC_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define ind(mm,x) (*(uint *)((uchar *)(mm) + ((x) & (255 << 2))))
//#define ind(mm,x) (*(uint *)((uint *)(mm) + (((x) >> 2) & 255)))
#define rngstep(mix,a,b,mm,m,m2,r,x) \
{\
	x = *m; \
	a = (a ^ (mix)) + *(m2++); \
	*(m++) = y = ind(mm, x) + a + b; \
	*(r++) = b = ind(mm, y >> 8) + x; \
}

#define ISAAC_RANDSIZL   (4)
#define ISAAC_RANDSIZ    (1<<ISAAC_RANDSIZL)

typedef struct{
  uint rr[ISAAC_RANDSIZ];
  uint mm[ISAAC_RANDSIZ];
  uint aa;
  uint bb;
  uint cc;
  uint idx;
} isaac_state;


void isaac_advance(isaac_state* state){
	//if(get_global_id(0)==0)printf("advance\n");
	uint a, b, x, y, *m, *m2, *r, *mend;
	m = state->mm;
	r = state->rr;
	a = state->aa;
	b = state->bb + (++state->cc);
	for (m = state->mm, mend = m2 = m+(ISAAC_RANDSIZ/2); m < mend; ){
		//if(m-state->mm>=ISAAC_RANDSIZ || m2-state->mm>=ISAAC_RANDSIZ) printf("first %d %d %d %d\n",get_global_id(0),(int)(m-state->mm), (int)(m2-state->mm), ISAAC_RANDSIZ);
		rngstep(a << 13, a, b, state->mm, m, m2, r, x);
		rngstep(a >> 6 , a, b, state->mm, m, m2, r, x);
		rngstep(a << 2 , a, b, state->mm, m, m2, r, x);
		rngstep(a >> 16, a, b, state->mm, m, m2, r, x);
	}
	for (m2 = state->mm; m2 < mend; ){
		//if(m-state->mm>=ISAAC_RANDSIZ || m2-state->mm>=ISAAC_RANDSIZ) printf("second %d %d %d %d\n",get_global_id(0),(int)(m-state->mm), (int)(m2-state->mm), ISAAC_RANDSIZ);
		rngstep(a << 13, a, b, state->mm, m, m2, r, x);
		rngstep(a >> 6 , a, b, state->mm, m, m2, r, x);
		rngstep(a << 2 , a, b, state->mm, m, m2, r, x);
		rngstep(a >> 16, a, b, state->mm, m, m2, r, x);
	}
	state->bb = b;
	state->aa = a;
}

#define isaac_uint(state) _isaac_uint(&state)

uint _isaac_uint(isaac_state* state){
	//printf("%d\n", get_global_id(0));
	if(state->idx == ISAAC_RANDSIZ){
		isaac_advance(state);
		state->idx=0;
	}
	return state->rr[state->idx++];
}

void isaac_seed(isaac_state* state, ulong j){
	state->aa = j;
	state->bb = j;
	state->cc = j;
	state->idx = ISAAC_RANDSIZ;
	for(int i=0;i<ISAAC_RANDSIZ+1;i++){
		state->mm[i]=j;
		isaac_advance(state);
	}
}

#define isaac_ulong(state) ((((ulong)isaac_uint(state)) << 32) | isaac_uint(state))
#define isaac_float(state) (isaac_uint(state)*ISAAC_FLOAT_MULTI)
#define isaac_double(state) (isaac_ulong(state)*ISAAC_DOUBLE_MULTI)
#define isaac_double2(state) (isaac_uint(state)*ISAAC_DOUBLE2_MULTI)