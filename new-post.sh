#! /bin/bash

echo "Creating page $1"
docker run --rm -v `pwd`:/src pkuehne/hugo new posts/$1.md
