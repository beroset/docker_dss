#!/bin/bash
SHARED_DIR="$(pwd)/work"
if [ ! -d "${SHARED_DIR}" ] 
then
    mkdir "${SHARED_DIR}"
fi
docker build -t beroset/build-opendss:v1 .
docker run --rm -v "${SHARED_DIR}":/tmp/work:z -t -i beroset/build-opendss:v1 /bin/bash -c make
