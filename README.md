# RandomCL

RandomCL is an OpenCL library for generating random numbers in parallel. It contains implementations of more than 20 random number generators.

# License

RandomCL is released under the BSD-3 license.

# Building 

The library itself does not need to be built - all code is contained in headers. Examples can be built using a makefile (TODO).

### Dependencies

- OpenCL library (examples, qualityTests and performanceTests require cpp OpenCL header).

# Documentation

There are two kinds of random number generators in RandomCL. Most generators are intended to have one instance of generator per thread. 
Their state is supposed to be saved in a private variable for each thread and threads can generate random numbers independantly. 
All of these have a similar interface. 

The xorshift1024 generator, however, has the state shared between 32 threads. Since state is saved in local memory it has a slightly different interface.

## Interface

Each generator is contained in its own header named `<NAME>.cl`. It defines the following type and functions, where `<NAME>` is the name of the generator:

#### `<NAME>_state`

Internal state of the generator. Different definition (and size) for each generator.

#### `void <NAME>_seed(<NAME>_state* state, ulong seed)`

Seeds the RNG using given seed. Seed should be different for each instance of the generator (thread).

#### `uint <NAME>_uint(<NAME>_state state)`

Advances state of the generator and generates a 32-bit unsigned integer. State is not a pointer, since it is implemented as a macro for some generators.

#### `ulong <NAME>_ulong(<NAME>_state state)`

Advances state of the generator and generates a 64-bit unsigned integer (unsigned long). State is not a pointer, since it is implemented as a macro for some generators.

#### `float <NAME>_float(<NAME>_state state)`

Advances state of the generator and generates a 32-bit floating point number between 0 and 1. State is not a pointer, since it is implemented as a macro for some generators.

#### `double <NAME>_double(<NAME>_state state)`

Advances state of the generator and generates a 64-bit floating point number (double) between 0 and 1. State is not a pointer, since it is implemented as a macro for some generators.

#### `double <NAME>_double2(<NAME>_state state)`

Advances state of the generator and generates a 64-bit floating point number (double) between 0 and 1. For generators, that internaly generate 32-bit numbers this can be faster then
`<NAME>_double(<NAME>_state state)`, as it is generated from 32-bit random number, instead of 64. State is not a pointer, since it is implemented as a macro for some generators.

# Generators

#### `msws`

Middle Square Weyl Sequence generator. Returns 64-bit numbers.  Not recomended for serious use, as paralell implementation does not pass BigCrush test.

#### `tyche`

Tyche generator. Modified to return 64 bit numbers.

#### `tyche_i`

Tyche-i generator. Uses inverse state transition function of Tyche and is usually faster. Modified to return 64 bit numbers. On a discrete GPU this generator is expected to be the fastest among generators that pass the BigCrush test. 

#### `tynimt32`

A 32-bit implementation of Tiny Mersenne Twister. Returns 32-bit numbers.

#### `tinymt64`

A 64-bit implementation of Tiny Mersenne Twister. Returns 64-bit numbers.

#### `pcg6432`

A 64-bit implementation of Permutated Congruential generator (PCG-XSH-RR). Returns 32-bit numbers.

#### `ran2`

Ran2 compound generator from Numerical Recipes book. Returns 64-bit numbers.

#### `kiss09`

KISS (Keep It Simple, Stupid) generator, proposed in 2009. Returns 64-bit numbers.

#### `kiss99`

KISS (Keep It Simple, Stupid) generator, proposed in 1999. Returns 32-bit numbers.

#### `lcg6432`

64-bit Linear Congruential Generator. Returns 32-bit numbers. Not recomended for serious use, as it does not pass BigCrush test.

#### `lcg12864`

128-bit Linear Congruential Generator. Returns 64-bit numbers.

#### `lfib`

Multiplicative Lagged Fibbonaci generator. Returns 64-bit random numbers, but the lowest bit is always 1.

#### `mrg31k3p`

Multiplicative Recursive Generator. Returns 32-bit random numbers.

#### `mrg63k3a`

Multiplicative Recursive Generator. Returns 64-bit random numbers, but the lowest bit is always 0.

#### `mt19937`

Mersenne Twister. Returns 32-bit random numbers.

#### `isaac`

ISAAC (Indirection, Shift, Accumulate, Add, and Count). Returns 32-bit random numbers. Does not work on graphics cards, as it requires unaligned accesses to memory.

#### `well512`

A 512-bit WELL (Well-Equidistributed Long-period Linear) implementation. Returns 32-bit random numbers.

#### `xorshift6432star`

Xorshift64/32* - 64-bit Xorshift generator with multiplication of output. Returns 32-bit numbers

#### `philox2x32_10`

Philox2x32-10. Returns 64-bit numbers.

#### `xorshift1024`

1024-bit xorshift generator. State is shared between 32 threads. As it uses barriers, all threads of a work group must call the generator at the same time, even if they do not require the result. In `localRNGs.h` header is the function `RNGLocal::xorshift1024_local_mem` that calculates required state size given local size. See "examplePrintLocal". 
