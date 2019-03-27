#Optionally specify the path to the OpenCL headers
#and uncomment the line below 
#CXXFLAGS+=-I../path/to/OpenCL/headers

CXX ?= g++
LDLIBS+=-lOpenCL

#On Windows specify the path to the OpenCL lib file
#the first commented line is the typicall path for NVIDIA GPUs
#the second is for AMD GPUS
#LDFLAGS_OPENCL= -L"$(CUDA_PATH)\lib\x64" -lOpenCL
#LDFLAGS_OPENCL= -L"$(AMDAPPSDKROOT)lib\x86_64" -lOpenCL
