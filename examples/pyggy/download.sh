#!/bin/bash

# This script downloads Pygmalion 6B model files that have already been converted to ggml format.
# This way you don't have to convert them yourself.


src="https://huggingface.co/alpindale/pygmalion-6b-ggml"
pfx="resolve/main/pygmalion-6b"

ggml_path=$(dirname $(realpath $0))

models=( "Main:v3" "V8P1:v8p1" "V8P2:v8p2" "V8P3:v8p3" "V8P4:v8p4" )
declare -A model_map=()
for i in "${models[@]}"; do
    key=${i%%:*}
    val=${i##*:}
    model_map["$key"]="$val"
done

function list_models {
    printf "\n"
    printf "  Available models:\n"
    for i in "${!model_map[@]}"; do
        printf "  %d. %s\n" $((++j)) "$i"
    done
    printf "\n"
}

list_models

read -s -p "Enter the number of the model you want to download: " choice

if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#model_map[@]} )); then
    printf "Invalid choice. Please enter a valid number.\n"
    exit 1
fi

model=${models[$choice - 1]%%:*}

technical_name=${model_map["$model"]}

printf "Downloading pyg model $model ...\n"

mkdir -p models/

if [ -x "$(command -v wget)" ]; then
    wget --quiet --show-progress -O models/pygmalion-6b-$technical_name-q4_0.bin $src/$pfx-$technical_name-q4_0.bin
elif [ -x "$(command -v curl)" ]; then
    curl -L --output models/pygmalion-6b-$technical_name-q4_0.bin $src/$pfx-$technical_name-q4_0.bin
else
    printf "Either wget or curl is required to download models.\n"
    exit 1
fi

if [ $? -ne 0 ]; then
    printf "Failed to download the pyg model $model \n"
    printf "Please try again or open an issue in the github page.\n"
    exit 1
fi

printf "Done! Model '$model' saved in 'models/pygmalion-6b-$model-q4_0.bin'\n"
printf "You can now use it like this:\n\n"
printf "  $ ./bin/pyggy -m models/pygmalion-6b-$model-q4_0.bin\n"
printf "\n"
