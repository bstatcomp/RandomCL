/**
@file

Implements 1024-bit xorshift generator. State is shared between 32 threads. As it uses barriers, 
all threads of a work group must call the generator at the same time, even if they do not require the 
result. In `localRNGs.h` header is the function `RNGLocal::xorshift1024_local_mem` that calculates required 
state size given local size. See "examplePrintLocal". 
*/

#pragma once
#define RNG_LOCAL

/*
* Updates the RNG state in cooperation with in -warp neighbors.
* Uses a block of shared memory of size
* (XORSHIFT1024_WARPSIZE + XORSHIFT1024_WORDSHIFT + 1) * NWARPS + XORSHIFT1024_WORDSHIFT + 1.
* Parameters:
* state: RNG state
* tid: thread index in block
* stateblock: shared memory block for states
* Returns:
* updated state
*/
#define XORSHIFT1024_FLOAT_MULTI 2.3283064365386962890625e-10f
#define XORSHIFT1024_DOUBLE2_MULTI 2.3283064365386962890625e-10
#define XORSHIFT1024_DOUBLE_MULTI 5.4210108624275221700372640e-20

#define XORSHIFT1024_WARPSIZE 32
#define XORSHIFT1024_WORD 32
#define XORSHIFT1024_WORDSHIFT 10
#define XORSHIFT1024_RAND_A 9
#define XORSHIFT1024_RAND_B 27
#define XORSHIFT1024_RAND_C 24

/**
State of xorshift1024 RNG.
*/
typedef uint xorshift1024_state;

/**
generates a random 32-bit unsigned integer using xorshift1024 RNG.

@param stateblock pointer to buffer in local memory, that holds state of the generator.
*/
uint xorshift1024_uint(local xorshift1024_state* stateblock){
	/* Indices. */
	int tid = get_local_id(0) + get_local_size(0) * (get_local_id(1) + get_local_size(1) * get_local_id(2));
	int wid = tid / XORSHIFT1024_WARPSIZE; // Warp index in block
	int lid = tid % XORSHIFT1024_WARPSIZE; // Thread index in warp
	int woff = wid * (XORSHIFT1024_WARPSIZE + XORSHIFT1024_WORDSHIFT + 1) + XORSHIFT1024_WORDSHIFT + 1;
	// warp offset
	/* Shifted indices. */
	int lp = lid + XORSHIFT1024_WORDSHIFT; // Left word shift
	int lm = lid - XORSHIFT1024_WORDSHIFT; // Right word shift

	uint state;
	
	/* << A. */
	state = stateblock[woff + lid]; // Read states
	state ^= stateblock[woff + lp] << XORSHIFT1024_RAND_A; // Left part
	state ^= stateblock[woff + lp + 1] >> (XORSHIFT1024_WORD - XORSHIFT1024_RAND_A); // Right part
	barrier(CLK_LOCAL_MEM_FENCE);

	/* >> B. */
	stateblock[woff + lid] = state; // Share states
	barrier(CLK_LOCAL_MEM_FENCE);
	state ^= stateblock[woff + lm - 1] << (XORSHIFT1024_WORD - XORSHIFT1024_RAND_B); // Left part
	state ^= stateblock[woff + lm] >> XORSHIFT1024_RAND_B; // Right part
	barrier(CLK_LOCAL_MEM_FENCE);

	/* << C. */
	stateblock[woff + lid] = state; // Share states
	barrier(CLK_LOCAL_MEM_FENCE);
	state ^= stateblock[woff + lp] << XORSHIFT1024_RAND_C; // Left part
	state ^= stateblock[woff + lp + 1] >> (XORSHIFT1024_WORD - XORSHIFT1024_RAND_C); // Right part
	barrier(CLK_LOCAL_MEM_FENCE);

	stateblock[woff + lid] = state; // Share states
	barrier(CLK_LOCAL_MEM_FENCE);
	
	return state;
}

/**
Seeds xorshift1024 RNG

@param stateblock Buffer in local memory, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void xorshift1024_seed(local xorshift1024_state* stateblock, ulong seed){
	int tid = get_local_id(0) + get_local_size(0) * (get_local_id(1) + get_local_size(1) * get_local_id(2));
	int wid = tid / XORSHIFT1024_WARPSIZE; // Warp index in block
	int lid = tid % XORSHIFT1024_WARPSIZE; // Thread index in warp
	int woff = wid * (XORSHIFT1024_WARPSIZE + XORSHIFT1024_WORDSHIFT + 1) + XORSHIFT1024_WORDSHIFT + 1;
	//printf("tid: %d, lid %d, wid %d, woff %d \n", tid, (uint)get_local_id(0), wid, woff);
	
	uint mem = (XORSHIFT1024_WARPSIZE + XORSHIFT1024_WORDSHIFT + 1) * (get_local_size(0) * get_local_size(1) * get_local_size(2) / XORSHIFT1024_WARPSIZE) + XORSHIFT1024_WORDSHIFT + 1;
	
	if(lid==13 && (uint)seed==0){ //shouldnt be seeded with all zeroes in wrap, but such check is simpler
		seed=1;
	}
	
	if(lid<XORSHIFT1024_WORDSHIFT + 1){
		//printf("%d setting %d to 0\n",(uint)get_global_id(0), woff - XORSHIFT1024_WORDSHIFT - 1 + lid);
		stateblock[woff - XORSHIFT1024_WORDSHIFT - 1 + lid] = 0;
	}
	if(tid<XORSHIFT1024_WORDSHIFT + 1){
		//printf("%d setting2 %d to 0\n",(uint)get_global_id(0), mem - 1 - tid);
		stateblock[mem - 1 - tid] = 0;
	}
	stateblock[woff + lid] = (uint)seed;
	//printf("%d seed set\n",(uint)get_local_id(0));
	barrier(CLK_LOCAL_MEM_FENCE);
	//printf("%d after barrier\n",(uint)get_local_id(0));
}
/**
generates a random 64-bit unsigned integer using xorshift1024 RNG.

@param stateblock pointer to buffer in local memory, that holds state of the generator.
*/
#define xorshift1024_ulong(state) ((((ulong)xorshift1024_uint(state)) << 32) | xorshift1024_uint(state))

/**
generates a random float between 0 and 1 using xorshift1024 RNG.

@param stateblock pointer to buffer in local memory, that holds state of the generator.
*/
#define xorshift1024_float(state) (xorshift1024_uint(state)*XORSHIFT1024_FLOAT_MULTI)
/**
generates a random double between 0 and 1 using xorshift1024 RNG.

@param stateblock pointer to buffer in local memory, that holds state of the generator.
*/
#define xorshift1024_double(state) (xorshift1024_ulong(state)*XORSHIFT1024_DOUBLE_MULTI)
/**
generates a random double between 0 and 1 using xorshift1024 RNG. Generated using only 32 random bits.

@param stateblock pointer to buffer in local memory, that holds state of the generator.
*/
#define xorshift1024_double2(state) (xorshift1024_uint(state)*XORSHIFT1024_DOUBLE2_MULTI)