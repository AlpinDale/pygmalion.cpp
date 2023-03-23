#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

read -p "$(echo -e "${YELLOW}Number of tokens to generate:${NC} ")" N_TOKENS
read -p "$(echo -e "${YELLOW}Top-K sampling:${NC} ")" TOP_K
read -p "$(echo -e "${YELLOW}Top-P sampling:${NC} ")" TOP_P
read -p "$(echo -e "${YELLOW}Batch size:${NC} ")" BATCH_SIZE
read -p "$(echo -e "${YELLOW}Temperature:${NC} ")" TEMPERATURE
read -p "$(echo -e "${YELLOW}Prompt:${NC} ")" PROMPT

# Replace any double quotes with single quotes in the prompt
PROMPT=${PROMPT//\"/\'}

echo -e "${GREEN}Running pygmalion.cpp...${NC}"
./build/bin/pyggy -m examples/pyggy/models/pygmalion-6b-q4_0.bin \
                  -n $N_TOKENS \
                  --top_k $TOP_K \
                  --top_p $TOP_P \
                  -b $BATCH_SIZE \
                  --temp $TEMPERATURE \
                  -p "$PROMPT"
