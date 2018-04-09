/**
 * @file
 * This example shows how to use a random number generator to calculate pi. On OpenCL device random points
 * are generated in 2 dimensions with coordinates between 0 and 1. Ones within the unit circle are counted
 * to estimate area of the unit circle. Equation for area of a circle is used to calculate pi from this estimate.
 
 * This example uses msws generator. Any other generator from the library could be used (except one
 * that requires local memory for storing its state - xorshift1024) simply by replacing all occurances
 * of "msws" with the name of desired generator in kernel source.
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
#define GENERATOR_LOCATION "..\\generators\\"
#else
#define GENERATOR_LOCATION "../generators/"
#endif
#define N_THREADS 1024*8
#define ITERS_PER_THREAD 10000

#define COMPILE_OPTS "-I " GENERATOR_LOCATION

static string kernelSource =
"#include <msws.cl>\n"
"\n"
"kernel void pi(uint iters, global ulong* seed, global uint* res){\n"
"    uint gid=get_global_id(0);\n"
"    msws_state state;\n"
"    msws_seed(&state,seed[gid]);\n"
"    uint cnt=0;\n"
"    for(uint i=0;i<iters;i++){\n"
"        float a=msws_float(state);\n"
"        float b=msws_float(state);\n"
"        if(a * a + b * b < 1.f){\n"
"            cnt++;\n"
"        }\n"
"    }\n"
"    res[gid]=cnt;"
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
	Buffer cl_seed(context, seed.begin(), seed.end(),false);
	Buffer cl_res(context, CL_MEM_WRITE_ONLY, N_THREADS * sizeof(cl_uint));
	cl_uint iters = ITERS_PER_THREAD;
	kernel.setArg(0, sizeof(iters), &iters);
	kernel.setArg(1, cl_seed);
	kernel.setArg(2, cl_res);
	queue.enqueueNDRangeKernel(kernel, NULL, NDRange(N_THREADS), NullRange, nullptr, &e);
	e.wait();
	vector<cl_uint> res(N_THREADS);
	queue.enqueueReadBuffer(cl_res, true, 0, N_THREADS * sizeof(cl_uint), &res[0], nullptr);
	//calculate pi
	cl_ulong total = 0;
	for (cl_uint threadCount : res) {
		total += threadCount;
	}
	double pi = static_cast<double>(total) / (ITERS_PER_THREAD*N_THREADS) * 4;
	//print results
	cout << "Calculated pi value: " << pi << endl;
	cout << "pi value from library: " << CL_M_PI << endl;
	cout << "difference: " << CL_M_PI - pi << endl;
}
