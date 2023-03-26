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

- [X] Example of Pygmalion-6B inference [examples/pyggy](https://github.com/AlpinDale/pygmalion.cpp/tree/master/examples/pyggy)
- [X] Support 4-bit integer quantization
- [X] Chat mode - **Now implemented!**
- [ ] Clean up the code


## Pygmalion-6B inference (example)

With ggml you can efficiently run [Pygmalion-6B](examples/pyggy) inference on the CPU.

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

## Android guide


You need an android phone with at least 8GB of RAM.

1. Install [Termux](https://play.google.com/store/apps/details?id=com.termux) from the Google Play Store.

If Google Play Store says your phone is too new, download from [here](https://f-droid.org/repo/com.termux_118.apk).

2. Run the automatic installer:
```bash
curl https://raw.githubusercontent.com/AlpinDale/pygmalion.cpp/main/install-droid.sh | bash
```
3. Run pygmalion.cpp by running these inside Termux:
```
chmod +x start.sh
./start.sh`
```

#### Manual setup on Android:

1. 1. Install [Termux](https://play.google.com/store/apps/details?id=com.termux) from the Google Play Store.

If Google Play Store says your phone is too new, download from [here](https://f-droid.org/repo/com.termux_118.apk).

2. Open Termux and run each of the commands below in order:
```bash
pkg install clang wget

apt install git build-essential

git clone https://github.com/AlpinDale/pygmalion.cpp && cd pygmalion.cpp

mkdir build && cd build

cmake ..

make pyggy
```

This will install `pygmalion.cpp`. To download the model, run:
```
chmod +x ../examples/pyggy/download-pyg.sh

../examples/pyggy/download-pyg.sh
```

And to run `pygmalion.cpp` (**make sure you replace the prompt with whatever you want, keep the quotations**):
```
./bin/pyggy -m models/pygmalion-6b-q4_0.bin -n 50 -p "Your prompt here."
```

For more information, checkout the corresponding programs in the [examples](examples) folder.
