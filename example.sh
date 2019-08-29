#!/bin/bash
SHARED_DIR="$(pwd)/shared"
if [ ! -d "${SHARED_DIR}" ]
then
    mkdir "${SHARED_DIR}"
fi
cp "$1" "${SHARED_DIR}"
docker run --rm -v "${SHARED_DIR}":/mnt/host-dir:z -t -i beroset/opendss "/mnt/host-dir/$1"
