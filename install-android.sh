#!/bin/bash

echo "Installing required packages..."
pkg install clang wget
apt install git build-essential

echo "Cloning pygmalion.cpp repository..."
git clone https://github.com/AlpinDale/pygmalion.cpp && cd pygmalion.cpp

echo "Creating build directory..."
mkdir build && cd build

echo "Configuring CMake..."
cmake ..

echo "Building pyggy..."
make pyggy

read -p "Do you want to download the model now? [y/n]: " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "The model takes up 3.6GB of space."
  read -p "Are you sure you want to download it now? [y/n]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Downloading the model..."
    chmod +x ../examples/pyggy/download-pyg.sh
    ../examples/pyggy/download-pyg.sh
  else
    echo "Model download cancelled."
  fi
else
  echo "All done! If you want to use the model, please run the 'start.sh' script."
fi
