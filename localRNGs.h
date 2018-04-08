#define CL_USE_DEPRECATED_OPENCL_1_2_APIS // cl.hpp
#if defined(__APPLE__) || defined(__MACOSX)
#include <OpenCL/cl.hpp>
#else
#include <CL/cl.hpp>
#endif

namespace RNGLocal {
	typedef cl_uint xorshift1024_state;
	int xorshift1024_local_mem(size_t local) {
		static const size_t warpsize = 32;
		static const size_t wordshift = 10;
		if(local % warpsize != 0) {
			throw std::exception();
		}
		return (warpsize + wordshift + 1) * (local / warpsize) + wordshift + 1;
	}
}