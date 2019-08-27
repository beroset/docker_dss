#!/bin/bash
docker build -t beroset/build-opendss:v1 .
docker run --rm -v /home/ejb/projects/epri/docker_dss/work:/tmp/work:z -t -i beroset/build-opendss:v1 /bin/bash -c make
