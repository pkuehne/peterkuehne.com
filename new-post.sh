#! /bin/bash

echo "Creating page $1"
PAGE=${1%.md}
docker run --rm -v `pwd`:/src pkuehne/hugo new posts/${PAGE}.md
