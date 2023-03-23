#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

if [ -d "pygmalion.cpp" ]; then
  read -p "$(echo -e "${YELLOW}The pygmalion.cpp folder already exists. Do you want to delete it and start fresh? [y/n]${NC}")" -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Deleting pygmalion.cpp folder...${NC}"
    rm -rf pygmalion.cpp
  else
    echo -e "${GREEN}Continuing with existing pygmalion.cpp folder...${NC}"
  fi
fi

echo -e "${GREEN}Installing required packages...${NC}"
pkg install clang wget -y
apt install git build-essential -y

echo -e "${GREEN}Cloning pygmalion.cpp repository...${NC}"
git clone https://github.com/AlpinDale/pygmalion.cpp && cd pygmalion.cpp

echo -e "${GREEN}Compiling pyggy...${NC}"
mkdir build && cd build
cmake ..
make pyggy

read -p "$(echo -e "${YELLOW}Do you want to download the model now? (3.6GB) [y/n]${NC}")" REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${GREEN}Downloading model...${NC}"
  chmod +x ../examples/pyggy/download-pyg.sh
  ../examples/pyggy/download-pyg.sh
fi

cd ../..
