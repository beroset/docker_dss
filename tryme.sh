#!/bin/bash
podman run --rm -itv "$(pwd)/shared":/mnt/host-dir:z --entrypoint=/bin/sh beroset/opendss
