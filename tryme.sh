#!/bin/bash
podman run --rm -itv "$(pwd)/shared":/mnt/host:z --entrypoint=/bin/sh beroset/opendss
