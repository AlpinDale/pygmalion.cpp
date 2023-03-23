#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

URL="https://huggingface.co/alpindale/pygmalion-6b-ggml-4bit/resolve/main/pygmalion-6b-q4_0.bin"
FILENAME="pygmalion-6b-q4_0.bin"

if [ ! -d "models" ]; then
  mkdir models
fi

if [ -f "models/$FILENAME" ]; then
  if [ $(md5sum models/$FILENAME | cut -d' ' -f1) = "dd46de7882a7dcbbf46e36f64794680b" ]; then
    echo -e "${YELLOW}File already exists and MD5 hash matches!${NC}"
    exit 0
  else
    read -p "$(echo -e "${YELLOW}File already exists. Do you want to resume the download? [y/n]${NC}")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo -e "${GREEN}Resuming download...${NC}"
      wget -c -q --show-progress $URL -P models/ -O $FILENAME
    else
      echo -e "${YELLOW}Deleting file and re-downloading.${NC}"
      rm -f models/$FILENAME
    fi
  fi
fi

if [ ! -f "models/$FILENAME" ]; then
  echo -e "${GREEN}Downloading file...${NC}"
  wget -c -q --show-progress $URL -P models/ -O $FILENAME
fi

if [ $(md5sum models/$FILENAME | cut -d' ' -f1) = "dd46de7882a7dcbbf46e36f64794680b" ]; then
  echo -e "${GREEN}Download complete and MD5 hash matches!${NC}"
else
  echo -e "${YELLOW}Download complete but MD5 hash doesn't match. Please try again.${NC}"
  rm -f models/$FILENAME
fi
