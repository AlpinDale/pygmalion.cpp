# pygmalion.cpp

Forked from [ggerganov/ggml](https://github.com/ggerganov/ggml).

## Features

- Written in C
- 16-bit float support
- 4-bit integer support
- Automatic differentiation (WIP in progress)
- ADAM and L-BFGS optimizers
- Optimized for Apple silicon via NEON intrinsics and Accelerate framework
- On x86 architectures utilzes AVX intrinsics
- No third-party dependencies
- Zero memory allocations during runtime

## Roadmap

- [X] Example of Pygmalion-6B inference [examples/gpt-j](https://github.com/ggerganov/ggml/tree/master/examples/pyggy)
- [X] Support 4-bit integer quantization
- [ ] Chat mode


## GPT inference (example)

With ggml you can efficiently run [GPT-2](examples/gpt-2) and [GPT-J](examples/gpt-j) inference on the CPU.

Here is how to run the example programs:

```bash
# Build pygmalion.cpp + examples
git clone https://github.com/AlpinDale/pygmalion.cpp
cd pygmalion.cpp
mkdir build && cd build
cmake ..
make -j4 pyggy

# Run the Pygmalion 6B model (quantized to 4-bits, requires around 6GB of RAM for full ctx)
../examples/pyggy/download-pyg.sh
./bin/pyggy -m models/pygmalion-6b-q4_0.bin -p "This is an example"
```


For more information, checkout the corresponding programs in the [examples](examples) folder.
