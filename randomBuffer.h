#pragma once

#define CL_USE_DEPRECATED_OPENCL_1_2_APIS // cl.hpp
#if defined(__APPLE__) || defined(__MACOSX)
#include <OpenCL/cl.hpp>
#else
#include <CL/cl.hpp>
#endif

#include <string>


namespace randomCL {
	/**
	location, where generators (.cl files) are saved
	*/
	extern std::string generatorLocation;

	/**
	Generates a buffer of random numbers (on a fast device using this and reading random numbers from global memory can be significantly
	slower than generating numbers on-the-fly in kerner where they are used).

	@param num how many numbers to generate
	@param generatorName which RNG to use. Valid is any name of RNG implemented in RandomCL
	@param queue OpenCL CommandQueue to use
	@param global number of threads to use for generation
	@param local number of threads in a work group
	@param type type of numbers to generate. Valid options are: "float", "double", "uint", "ulong"
	@param seed set seed for repeatable generation.
	*/
	cl::Buffer generateRandomBuffer(unsigned int num, std::string generatorName, cl::CommandQueue queue, size_t global, size_t local, std::string type = "float", unsigned long long seed = 0);
}