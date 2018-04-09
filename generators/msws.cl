/**
@file

Implements msws (Middle Square Weyl Sequence) RNG.
*/
#pragma once

#define MSWS_FLOAT_MULTI 5.4210108624275221700372640e-20f
#define MSWS_DOUBLE_MULTI 5.4210108624275221700372640e-20

/**
State of msws RNG.
*/
typedef struct{
	union{
		ulong x;
		uint2 x2;
	};
	ulong w;
}msws_state;

/**
Generates a random 64-bit unsigned integer using msws RNG.

This is alternative, macro implementation of msws RNG.

@param state State of the RNG to use.
*/
#define msws_macro_ulong(state) (\
	state.x *= state.x, \
	state.x += (state.w += 0xb5ad4eceda1ce2a9), \
	state.x = (state.x>>32) | (state.x<<32) \
	)

/**
Generates a random 64-bit unsigned integer using msws RNG.

@param state State of the RNG to use.
*/
#define msws_ulong(state) _msws_ulong(&state)
ulong _msws_ulong(msws_state* state){
	state->x *= state->x;
	state->x += (state->w += 0xb5ad4eceda1ce2a9);
	return state->x = (state->x>>32) | (state->x<<32);
}

/**
Generates a random 64-bit unsigned integer using msws RNG.

This is alternative implementation of msws RNG, that swaps values instead of using shifts.

@param state State of the RNG to use.
*/
#define msws_swap_ulong(state) _msws_swap_ulong(&state)
ulong _msws_swap_ulong(msws_state* state){
	state->x *= state->x;
	state->x += (state->w += 0xb5ad4eceda1ce2a9);
	/*uint tmp = state->xl;
	state->xl = state->xh;
	state->xh = tmp;*/
	state->x2 = state->x2.yx;
	return state->x;
}
/**
Generates a random 64-bit unsigned integer using msws RNG.

This is second alternative implementation of msws RNG, that swaps values instead of using shifts.

@param state State of the RNG to use.
*/
#define msws_swap2_ulong(state) _msws_swap2_ulong(&state)
ulong _msws_swap2_ulong(msws_state* state){
	state->x *= state->x;
	state->x += (state->w += 0xb5ad4eceda1ce2a9);
	uint tmp = state->x2.x;
	state->x2.x = state->x2.y;
	state->x2.y = tmp;
	return state->x;
}

/**
Seeds msws RNG.

@param state Variable, that holds state of the generator to be seeded.
@param seed Value used for seeding. Should be randomly generated for each instance of generator (thread).
*/
void msws_seed(msws_state* state, ulong j){
	state->x = j;
	state->w = j;
}

/**
Generates a random 32-bit unsigned integer using msws RNG.

@param state State of the RNG to use.
*/
#define msws_uint(state) ((uint)msws_ulong(state))

/**
Generates a random float using msws RNG.

@param state State of the RNG to use.
*/
#define msws_float(state) (msws_ulong(state)*MSWS_FLOAT_MULTI)

/**
Generates a random double using msws RNG.

@param state State of the RNG to use.
*/
#define msws_double(state) (msws_ulong(state)*MSWS_DOUBLE_MULTI)

/**
Generates a random double using msws RNG. Since msws returns 64-bit numbers this is equivalent to msws_double.

@param state State of the RNG to use.
*/
#define msws_double2(state) msws_double(state)