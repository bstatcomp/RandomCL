#pragma once

#include "randomBuffer.h"
#include "localRNGs.h"
#define CL_USE_DEPRECATED_OPENCL_1_2_APIS // cl.hpp
#if defined(__APPLE__) || defined(__MACOSX)
#include <OpenCL/cl.hpp>
#include <OpenCL/cl.h>
#else
#include <CL/cl.hpp>
#include <CL/cl.h>
#endif

#include <string>
#include <random>
#include <map>

using cl::Buffer;
using cl::Program;
using cl::Platform;
using cl::Device;
using cl::Kernel;
using cl::Context;
using cl::CommandQueue;
using cl::Event;
using cl::NDRange;
using namespace std;

#include <iostream>


#ifdef _WIN32
#define GENERATOR_LOCATION "..\\generators\\"
#else
#define GENERATOR_LOCATION "../generators/"
#endif

static string generateBufferKernel(string name, string type) {
	return
		string((type=="double") ? " #pragma OPENCL EXTENSION cl_khr_fp64 : enable \n" : "") +
		"#include <" + name + ".cl>\n"
		"\n"
		"kernel void generate(uint num, global ulong* seed, global " + type + "* res){\n"
		"    uint gid=get_global_id(0);\n"
		"    uint gsize=get_global_size(0);\n"
		"    " + name + "_state state;\n"
		"    " + name + "_seed(&state,seed[gid]);\n"
		"    for(uint i=gid;i<num;i+=gsize){\n"
		"        res[i]=" + name + "_" + type + "(state);\n"
		"    }\n"
		"}";
}

static string generateBufferKernelLocal(string name, string type) {
	return
		string((type == "double") ? " #pragma OPENCL EXTENSION cl_khr_fp64 : enable \n" : "") +
		"#include <" + name + ".cl>\n"
		"\n"
		"kernel void generate(uint num, global ulong* seed, global " + type + "* res, local " + name + "_state* state){\n"
		"    uint gid=get_global_id(0);\n"
		"    uint gsize=get_global_size(0);\n"
		"\n"
		"    " + name + "_seed(state,seed[gid]);\n"
		"    uint num_gsize = ((num - 1) / gsize + 1)*gsize; //next multiple of gsize, larger or equal to N\n"
		"    for (int i = gid; i<num_gsize; i += gsize) {\n"
		"        " + type + " val = " + name + "_" + type + "(state); //all threads within workgroup must call generator, even if result is not needed!\n"
		"        if (i<num) {\n"
		"     	     res[i] = val;\n"
		"     	 }\n"
		"    }\n"
		"}";
}
std::string randomCL::generatorLocation = GENERATOR_LOCATION;
Buffer randomCL::generateRandomBuffer(unsigned int num, string generatorName, CommandQueue queue, size_t global, size_t local, string type, unsigned long long seed) {
	Context context = queue.getInfo<CL_QUEUE_CONTEXT>();
	Device device = queue.getInfo<CL_QUEUE_DEVICE>();
	size_t size;
	if (type == "float" || type == "uint") {
		size = num * 4;
	}
	else if (type == "double" || type == "ulong") {
		size = num * 8;
	}
	else {
		throw exception("can only generate numbers of types: uint, ulong, float, double!");
	}
	vector<cl_ulong> seeds(global);
	mt19937_64 generator(seed);
	for (int i = 0; i < global; i++) {
		seeds[i] = generator();
	}
	bool isLocalGenerator = generatorName == "xorshift1024";
	//dont recompile kernel every time
	static map<tuple<string, string, cl_command_queue>, Kernel> cache;
	Kernel kernel;
	tuple<string, string, cl_command_queue> tmp = make_tuple(generatorName, type, queue());
	if (cache.count(tmp)) {
		kernel = cache[tmp];
	}
	else {
		string kernelSource;
		if (isLocalGenerator) {
			kernelSource = generateBufferKernelLocal(generatorName, type);
		}
		else {
			kernelSource = generateBufferKernel(generatorName, type);
		}
		Program::Sources sources(1, make_pair(kernelSource.c_str(), kernelSource.length()));
		Program program(context, sources);
		program.build(vector<Device>({ device }), ("-I " + generatorLocation).c_str());
		cout << "CL Build info: " << program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device) << "\n";
		kernel = Kernel(program, "generate");
		cache[tmp] = kernel;
	}
	Event e;
	Buffer cl_seed(context, seeds.begin(), seeds.end(), true);
	Buffer cl_res(context, CL_MEM_WRITE_ONLY, size);
	kernel.setArg(0, sizeof(num), &num);
	kernel.setArg(1, cl_seed);
	kernel.setArg(2, cl_res);
	if (isLocalGenerator) {
		kernel.setArg(3, cl::Local(randomCL::local::xorshift1024_local_mem(local) * sizeof(randomCL::local::xorshift1024_state))); //calculates amount of local memory needed from local size
	}
	queue.enqueueNDRangeKernel(kernel, NULL, NDRange(global), NDRange(local));
	e.wait();
	return cl_res;
}