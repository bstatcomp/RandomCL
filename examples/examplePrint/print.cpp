/*
 * In this example we use OpenCL device to generate NUM 32-bit random numbers. These are then transfered to host 
 * and printed.
 
* This example uses tyche_i generator. Any other generator from the library could be used (except one
* that requires local memory for storing its state - xorshift1024) simply by replacing all occurances
* of "tyche_i" with the name of desired generator in the kernel source.
 */

#define CL_USE_DEPRECATED_OPENCL_1_2_APIS // cl.hpp
#if defined(__APPLE__) || defined(__MACOSX)
#include <OpenCL/cl.hpp>
#else
#include <CL/cl.hpp>
#endif
#include <chrono>
#include <random>
#include <iostream>

using cl::Buffer;
using cl::Program;
using cl::Platform;
using cl::Device;
using cl::Kernel;
using cl::Context;
using cl::CommandQueue;
using cl::Event;
using cl::NDRange;
using cl::NullRange;
using namespace std;

#define PLATFORM 0
#define DEVICE 0
#ifdef _WIN32
#define GENERATOR_LOCATION "..\\..\\generators\\"
#else
#define GENERATOR_LOCATION "../../generators/"
#endif
#define N_THREADS 128
#define NUM 2000

#define COMPILE_OPTS "-I " GENERATOR_LOCATION

static string kernelSource =
"#include <tyche_i.cl>\n"
"\n"
"kernel void pi(uint num, global ulong* seed, global uint* res){\n"
"    uint gid=get_global_id(0);\n"
"    uint gsize=get_global_size(0);\n"
"    tyche_i_state state;\n"
"    tyche_i_seed(&state,seed[gid]);\n"
"    for(uint i=gid;i<num;i+=gsize){\n"
"        res[i]=tyche_i_uint(state);\n"
"    }\n"
"}";

int main(int argc, char* argv[]) {
	//prepare command queue
	vector<Platform> platforms;
	Platform::get(&platforms);
	vector<Device> devices;
	platforms[PLATFORM].getDevices(CL_DEVICE_TYPE_ALL, &devices);
	Device device = devices[DEVICE];
	Context context({ device });
	CommandQueue queue(context, device);
	//build kernel
	Program::Sources sources(1, make_pair(kernelSource.c_str(), kernelSource.length()));
	Program program(context, sources);
	program.build(vector<Device>({ device }), COMPILE_OPTS);
	cout << "CL Build info: " << program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device) << "\n";
	Kernel kernel(program, "pi");
	//generade a seed for each thread
	vector<cl_ulong> seed(N_THREADS);
	long long rnd_init = chrono::system_clock::now().time_since_epoch().count();
	mt19937_64 generator(rnd_init);
	for (int i = 0; i < N_THREADS; i++) {
		seed[i] = generator();
	}
	//create buffers, set kernel arguments and run
	Event e;
	Buffer cl_seed(context, seed.begin(), seed.end(), false);
	Buffer cl_res(context, CL_MEM_WRITE_ONLY, NUM * sizeof(cl_uint));
	cl_uint num = NUM;
	kernel.setArg(0, sizeof(num), &num);
	kernel.setArg(1, cl_seed);
	kernel.setArg(2, cl_res);
	queue.enqueueNDRangeKernel(kernel, NULL, NDRange(N_THREADS), NullRange, nullptr, &e);
	e.wait();
	vector<cl_uint> res(NUM);
	queue.enqueueReadBuffer(cl_res, true, 0, NUM * sizeof(cl_uint), &res[0]);
	//print results
	for(cl_uint num: res) {
		cout << num <<" ";
	}
}