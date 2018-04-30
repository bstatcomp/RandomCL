/**
@file

Implementzs function for calculation of required local buffer size of local RNG.
*/
#pragma once

#define CL_USE_DEPRECATED_OPENCL_1_2_APIS // cl.hpp
#if defined(__APPLE__) || defined(__MACOSX)
#include <OpenCL/cl.hpp>
#else
#include <CL/cl.hpp>
#endif
namespace randomCL {
	namespace local {
		typedef cl_uint xorshift1024_state;
		/**
		Calculates required size of local buffer for xorshift1024 RNG.

		@param local Number of threads in work group that will be run.
		*/
		int xorshift1024_local_mem(size_t local) {
			static const size_t warpsize = 32;
			static const size_t wordshift = 10;
			if (local % warpsize != 0) {
				throw std::exception();
			}
			return (warpsize + wordshift + 1) * (local / warpsize) + wordshift + 1;
		}
	}
}