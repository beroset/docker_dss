#!/bin/bash
SHARED_DIR="$(pwd)/work"
docker run --rm -v "${SHARED_DIR}":/tmp/work:z -t -i fedora:latest /tmp/work/test.sh StevensonPflow-3ph.dss
