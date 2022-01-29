#!/bin/bash

key1=${1}
key2=${2}

add_to_dockerfile ${input} (
  while IFS= read -r line
  do
    echo "$line" >> Dockerfile
  done < "$input"
)

rm -rf Dockerfile
add_to_dockerfile ".\docker\Dockerfile.base"
add_to_dockerfile ${key1}

docker build --pull --rm -f "Dockerfile" -t ${key2}