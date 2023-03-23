# Pygmalion-6B

Local Pygmalion-6B inference on your computer using C/C++

No video card required. You just need to have 16 GB of RAM.

## Motivation

It seemed like fun.

***

Here is a sample run with prompt `int main(int argc, char ** argv) {`:

```
$ time ./bin/pygmalion-6b-q4_0.bin -p "int main(int argc, char ** argv) {"

gptj_model_load: loading model from 'models/gpt-j-6B/ggml-model.bin' - please wait ...
gptj_model_load: n_vocab = 50400
gptj_model_load: n_ctx   = 2048
gptj_model_load: n_embd  = 4096
gptj_model_load: n_head  = 16
gptj_model_load: n_layer = 28
gptj_model_load: n_rot   = 64
gptj_model_load: f16     = 1
gptj_model_load: ggml ctx size = 13334.86 MB
gptj_model_load: memory_size =  1792.00 MB, n_mem = 57344
gptj_model_load: ................................... done
gptj_model_load: model size = 11542.79 MB / num tensors = 285
main: number of tokens in prompt = 13

int main(int argc, char ** argv) {
    (void)argc;
    (void)argv;

    {
        struct sockaddr_in addr;
        int addrlen;
        char * ip = "192.168.1.4";
        int i;

        if ( (addrlen = sizeof(addr)) == -1 )
            return -1;

        for (i = 0; i < 10; ++i) {
            addr.sin_family = AF_INET;
            addr.sin_addr.s_addr = inet_addr(ip);

main: mem per token = 16430420 bytes
main:     load time =  6211.48 ms
main:   sample time =    13.74 ms
main:  predict time = 26420.34 ms / 124.62 ms per token
main:    total time = 33035.37 ms

real	0m33.171s
user	3m32.269s
sys      0m3.686s

$
```


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