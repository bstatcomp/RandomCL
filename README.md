# RandomCL

RandomCL is an OpenCL library for generating random numbers in parallel. It contains implementations of more than 20 random number generators. While it is intended for usage on graphics processing units (GPUs), the generators can run on any OpenCL-enabled device.
The article (An OpenCL library for parallel random number generators)[https://link.springer.com/article/10.1007%2Fs11227-019-02756-2] contains further details about implementation and testing of the library.

# License

RandomCL is released under the BSD-3 license.

# Building 

RNGs do not need to be built - all code is contained in headers. Examples and buffer generation can be built using a makefile (TODO).

### Dependencies

- OpenCL library (examples and buffer generation require cpp OpenCL header).

# Documentation

There are two kinds of random number generators in RandomCL. Most generators are intended to have one instance of generator per thread. 
Their state is supposed to be saved in a private variable for each thread and threads can generate random numbers independantly. 
All of these have a similar interface. 

The xorshift1024 generator, however, has the state shared between 32 threads. Since state is saved in local memory it has a slightly different interface.

## OpenCL Interface

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

[B. Widynski, Middle square Weyl sequence rng, arXiv preprint arXiv:1704.00358. https://arxiv.org/abs/1704.00358](https://arxiv.org/abs/1704.00358)

#### `tyche`

Tyche generator. Modified to return 64 bit numbers.

S. Neves, F. Araujo, Fast and small nonlinear pseudorandom number generators for computer simulation, in: International Conference on Parallel Processing and Applied Mathematics, Springer, 2011, pp. 92–101.

#### `tyche_i`

Tyche-i generator. Uses inverse state transition function of Tyche and is usually faster. Modified to return 64 bit numbers. On a discrete GPU this generator is expected to be the fastest among generators that pass the BigCrush test. 

S. Neves, F. Araujo, Fast and small nonlinear pseudorandom number generators for computer simulation, in: International Conference on Parallel Processing and Applied Mathematics, Springer, 2011, pp. 92–101.

#### `tynimt32`

A 32-bit implementation of Tiny Mersenne Twister. Returns 32-bit numbers.

[Tiny mersenne twister, http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html.](http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html)

#### `tinymt64`

A 64-bit implementation of Tiny Mersenne Twister. Returns 64-bit numbers.

[Tiny mersenne twister, http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html.](http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html)

#### `pcg6432`

A 64-bit implementation of Permutated Congruential generator (PCG-XSH-RR). Returns 32-bit numbers.

M. E. O’Neill, Pcg: A family of simple fast space-efficient statistically good algorithms for random number generation, ACM Transactions on Mathematical Software.

#### `ran2`

Ran2 compound generator. Returns 64-bit numbers.

W. H. Press, S. A. Teukolsky, W. T. Vetterling, B. P. Flannery, Numerical recipes in c: The art of scientific computing (; cambridge (1992).

#### `kiss09`

KISS (Keep It Simple, Stupid) generator, proposed in 2009. Returns 64-bit numbers.

[G. Marsaglia, 64-bit kiss rngs, https://www.thecodingforums.com/threads/64-bit-kiss-rngs.673657.](https://www.thecodingforums.com/threads/64-bit-kiss-rngs.673657)

#### `kiss99`

KISS (Keep It Simple, Stupid) generator, proposed in 1999. Returns 32-bit numbers.

[G. Marsaglia, Random numbers for c: End, at last?, http://www.cse.yorku.ca/~oz/marsaglia-rng.html.](http://www.cse.yorku.ca/~oz/marsaglia-rng.html)

#### `lcg6432`

64-bit Linear Congruential Generator. Returns 32-bit numbers. Not recomended for serious use as it does not pass BigCrush test.

P. L’ecuyer, Tables of linear congruential generators of different sizes and good lattice structure, Mathematics of Computation of the American Mathematical Society 68 (225) (1999) 249–260.

#### `lcg12864`

128-bit Linear Congruential Generator. Returns 64-bit numbers.

P. L’ecuyer, Tables of linear congruential generators of different sizes and good lattice structure, Mathematics of Computation of the American Mathematical Society 68 (225) (1999) 249–260.

#### `lfib`

Multiplicative Lagged Fibbonaci generator. Returns 64-bit random numbers, but the lowest bit is always 1.

G. Marsaglia, L.-H. Tsay, Matrices and the structure of random number sequences, Linear algebra and its applications 67 (1985) 147–156.

#### `mrg31k3p`

Multiplicative Recursive Generator. Returns 32-bit random numbers.

P. L’Ecuyer, R. Touzin, Fast combined multiple recursive generators with multipliers of the form a=±2 q±2 r, in: Proceedings of the 32nd conference on Winter simulation, Society for Computer Simulation International, 2000, pp. 683–689.

#### `mrg63k3a`

Multiplicative Recursive Generator. Returns 64-bit random numbers, but the lowest bit is always 0.

P. L’ecuyer, Good parameters and implementations for combined multiple recursive random number generators, Operations Research 47 (1) (1999) 159–164.

#### `mt19937`

Mersenne Twister. Returns 32-bit random numbers.

M. Matsumoto, T. Nishimura, Mersenne twister: a 623-dimensionally equidistributed uniform pseudo-random number generator, ACM Transactions on Modeling and Computer Simulation (TOMACS) 8 (1) (1998) 3–30.

#### `isaac`

ISAAC (Indirection, Shift, Accumulate, Add, and Count). Returns 32-bit random numbers. Does not work on graphics cards, as it requires unaligned accesses to memory.

R. J. Jenkins, Isaac, in: International Workshop on Fast Software Encryption, Springer, 1996, pp. 41–49.

#### `well512`

A 512-bit WELL (Well-Equidistributed Long-period Linear) implementation. Returns 32-bit random numbers.

F. Panneton, P. L’ecuyer, M. Matsumoto, Improved long-period generators based on linear recurrences modulo 2, ACM Transactions on Mathematical Software (TOMS) 32 (1) (2006) 1–16.

#### `xorshift6432star`

Xorshift64/32* - 64-bit Xorshift generator with multiplication of output. Returns 32-bit numbers

S. Vigna, An experimental exploration of marsaglia’s xorshift generators, scrambled, ACM Transactions on Mathematical Software (TOMS) 42 (4) (2016) 30.

#### `philox2x32_10`

Philox2x32-10. Returns 64-bit numbers.

J. K. Salmon, M. A. Moraes, R. O. Dror, D. E. Shaw, Parallel random numbers: as easy as 1, 2, 3, in: High Performance Computing, Networking, Storage and Analysis (SC), 2011 International Conference for, IEEE, 2011, pp. 1–12.

#### `xorshift1024`

1024-bit xorshift generator. State is shared between 32 threads. As it uses barriers, all threads of a work group must call the generator at the same time, even if they do not require the result. In `localRNGs.h` header is the function `RNGLocal::xorshift1024_local_mem` that calculates required state size given local size. See "examplePrintLocal". 

M. Manssen, M. Weigel, A. K. Hartmann, Random number generators for massively parallel simulations on GPU, The European Physical Journal-Special Topics 210 (1) (2012) 53–71.

## Buffer Generation

### `cl::Buffer generateRandomBuffer(unsigned int num, std::string generatorName, cl::CommandQueue queue, size_t global, size_t local, std::string type = "float", unsigned long long seed = 0)`
Generates a buffer of random numbers (on a fast device using this and reading random numbers from global memory can be significantly
slower than generating numbers on-the-fly in kerner where they are used).

`num` how many numbers to generate

`generatorName` which RNG to use. Valid is any name of RNG implemented in RandomCL

`queue` OpenCL CommandQueue to use

`global` number of threads to use for generation

`local` number of threads in a work group

`type` type of numbers to generate. Valid options are: "float", "double", "uint", "ulong"

`seed` set seed for repeatable generation.