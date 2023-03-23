#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

echo -e "${GREEN}Installing required packages...${NC}"
sudo apt install clang wget -y
sudo apt install git build-essential -y

echo -e "${GREEN}Cloning pygmalion.cpp repository...${NC}"
git clone https://github.com/AlpinDale/pygmalion.cpp && cd pygmalion.cpp

echo -e "${GREEN}Compiling pyggy...${NC}"
mkdir build && cd build
cmake ..
make pyggy

read -p "$(echo -e "${YELLOW}Do you want to download the model now? (3.6GB) [y/n]${NC}")" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}Downloading model...${NC}"
  chmod +x ../examples/pyggy/download-pyg.sh
  ../examples/pyggy/download-pyg.sh
fi

cd ../..
