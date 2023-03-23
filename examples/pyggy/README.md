# Pygmalion-6B

Local Pygmalion-6B inference on your computer using C/C++

No video card required. You just need to have 6 GB of RAM.

## Motivation

It seemed like fun.

***

## Implementation details

The high level implementation of the model is contained in the [pyggy.cpp](pyggy.cpp) file. The core computations are
performed by the [ggml](https://github.com/AlpinDale/pygmalion.cpp/blob/main/include/ggml/ggml.h) library.


#### Matrix multiplication

The most performance critical part of the implementation is of course the matrix multiplication routine. 99% of the time
is spent here, so it was important to optimize this as much as possible.

On Arm64, I utilize the 128-bit NEON intrinsics for 16-bit floating point operations:

https://github.com/AlpinDale/pygmalion.cpp/blob/ca33c2e2df5e8960e4937ad1097497f072fa401f/src/ggml.cL187-L243

These instructions allow each core to operate simultaneously on 64 16-bit floats. I'm no expert in SIMD, but after quite
some trials this was the most efficient code for dot product of a row and column that I could come up with. Combined
with the parallel computation on 8 CPU threads, I believe I'm close to the maximum performance that one could possibly
get on the M1 CPU. Still, I'm curious to know if there is a more efficient way to implement this.


#### Attempt to use the M1 GPU

One interesting property of the GPT-J (Pygmalion-6B's base model) transformer architecture is that it allows you to perform part of the inference in
parallel - i.e. the Feed-forward network can be computed in parallel to the Self-attention layer:

https://github.com/AlpinDale/pygmalion.cpp/blob/ca33c2e2df5e8960e4937ad1097497f072fa401f/examples/pyggy/pyg.cpp#L507-L531

So I thought why not try and bring in the M1 GPU to compute half of the neural network in parallel to the CPU and
potentially gain some extra performance. Thanks to the M1's shared memory model, it was relatively easy to offload part
of the computation to the GPU using Apple's [Metal Performance
Shaders](https://developer.apple.com/documentation/metalperformanceshaders). The GPU shares the host memory, so there is
no need to copy the data back and forth as you would normally do with Cuda or OpenCL. The weight matrices are directly
available to be used by the GPU.

However, to my surprise, using MPS together with the CPU did not lead to any performance improvement at all. My
conclusion was that the 8-thread NEON CPU computation is already saturating the memory bandwidth of the M1 and since
the CPU and the GPU on the MacBook are sharing that bandwidth, it does not help to offload the computation to the GPU.
Another observation was that the MPS GPU matrix multiplication using 16-bit floats had the same performance as the
8-thread NEON CPU implementation. Again, I explain this with a saturated memory channel. But of course, my explanation
could be totally wrong and somehow the implementation wasn't utilizing the resources correctly.

In the end, I decided to not use MPS or the GPU all together.

### Zero memory allocations

Another property of my implementation is that it does not perform any memory allocations once the model is loaded into
memory. All required memory is allocated at the start of the program with a single `malloc` (technically 2 calls, but
that is not important).

## Usage

If you want to give this a try and you are on Linux or Mac OS, simply follow these instructions:

```bash
# Clone the ggml library and build the gpt-j example
git clone https://github.com/AlpinDale/pygmalion.cpp
cd pygmalion.cpp
mkdir build && cd build
cmake ..
make -j4 pyggy

# Download the ggml-compatible Pygmalion-6B model (requires 3.6GB disk space)
../examples/pyggy/download-pyg.sh

# Run the inference (requires 16GB of CPU RAM)
./bin/pyggy -m models/pygmalion-6b-q4_0.bin -p "This is an example"
```

To run the `pyggy` tool, you need the 3.6GB `pygmalion-6b-q4_0.bin` file which contains the Pygmalion-6B model in
[ggml](https://github.com/ggerganov/ggml) compatible format. In the instructions above, the binary file
is downloaded from my repository on Hugging Face using the [download-pyg.sh](download-ggml-model.sh) script.
You can also, download the file manually from this link:

https://huggingface.co/alpindale/pygmalion-6b-ggml-4bit/tree/main

---
