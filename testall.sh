#!/bin/bash

# This program builds and tests all of the variations of the
# beroset/opendss software container and then tests them all.
# The output should look something like this:
#
#    Build time for alpine: 225.998
#    Build time for arch: 174.521
#    Build time for centos: 359.120
#    Build time for debian: 12.693
#    Build time for fedora: 289.985
#    Build time for opensuse: 232.167
#    Build time for ubuntu: 8.336
#    [OK] alpine
#    [OK] arch
#    [OK] centos
#    [OK] debian
#    [OK] fedora
#    [OK] opensuse
#    [OK] ubuntu
# 
CONTAINER_ENGINE="podman"
DISTROLIST="alpine arch centos debian fedora opensuse ubuntu"
OK="\e[0;32mOK\e[m"
BAD="\e[0;31mFailed!\e[m"

build_one() (
    local distro="${1}"
    TIMEFORMAT='%R'
    printf $"Build time for %s: " "${distro}" 
    $(time { ${CONTAINER_ENGINE} build -f=work/Dockerfile.$distro -t beroset/opendss/$distro work >/dev/null 2>&1; }  2>&1 )
)

test_one() (
    local distro="${1}"
    local SHARED_DIR="$(pwd)/shared/"
    if [ ! -d "${SHARED_DIR}" ] ; then
        mkdir "${SHARED_DIR}"
    else
        rm -f "${SHARED_DIR}"*
    fi
    cp StevensonPflow-3ph.dss "${SHARED_DIR}"
    ${CONTAINER_ENGINE} run --rm -v "${SHARED_DIR}":/mnt/host-dir:z "beroset/opendss/${distro}" "/mnt/host-dir/StevensonPflow-3ph.dss" 1>/dev/null 2>&1
    if sha512sum -c checksums --status ; then
        echo -e "[${OK}] ${distro}"
    else
        echo -e "[${BAD}] ${distro}"
    fi
)

while test $# -gt 0; do 
    case "$1" in 
    --docker)
        echo 'Testing using Docker as the container engine'
        CONTAINER_ENGINE="docker"
        shift
        ;;
    --podman)
        echo 'Testing using Podman as the container engine'
        CONTAINER_ENGINE="podman"
        shift
        ;;
     --h | --he | --hel | --help)
        echo $"Usage: testall.sh [OPTION]
        --help              print this help and exit
        --podman            use Podman as the container engine
        --docker            use Docker as the container engine
"
        exit 0
        ;;
      --)    # stop option processing
        shift; break
        ;;
      -*)
        echo >&2 'testall.sh' $"unrecognized option" "\`$1'"
        echo >&2 $"Try \`testall.sh --help' for more information."
        exit 1
        ;;
      *)
        break
        ;;
    esac
done

for distro in ${DISTROLIST}; do
    build_one "${distro}"
done

for distro in ${DISTROLIST}; do
    test_one "${distro}" 
done
