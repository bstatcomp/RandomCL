/*
* This example shows how to generate an OpenCL buffer of random numbers. Here we transfer them to host and print them.

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
#include <randomBuffer.h>

using cl::Buffer;
using cl::Program;
using cl::Platform;
using cl::Device;
using cl::Kernel;
using cl::Context;
using cl::CommandQueue;
using namespace std;

#define PLATFORM 0
#define DEVICE 0
#define N_THREADS 128
#define NUM 2000

#ifdef _WIN32
#define GENERATOR_LOCATION "..\\..\\generators\\"
#else
#define GENERATOR_LOCATION "../../generators/"
#endif


int main(int argc, char* argv[]) {
	//prepare command queue
	vector<Platform> platforms;
	Platform::get(&platforms);
	vector<Device> devices;
	platforms[PLATFORM].getDevices(CL_DEVICE_TYPE_ALL, &devices);
	Device device = devices[DEVICE];
	Context context({ device });
	CommandQueue queue(context, device);
	//generate numbers
	randomCL::generatorLocation = GENERATOR_LOCATION;
	Buffer cl_res = randomCL::generateRandomBuffer(NUM, "tyche_i", queue, N_THREADS, 128, "double",12345);
	//transfer to host
	vector<cl_double> res(NUM);
	queue.enqueueReadBuffer(cl_res, true, 0, NUM * sizeof(cl_double), &res[0]);
	//print results
	for (cl_double num : res) {
		cout << num << " ";
	}
}