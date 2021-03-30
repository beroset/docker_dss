#!/bin/bash

# This program builds and tests all of the variations of the
# beroset/opendss software container and then tests them all.
# The output should look something like this:
#
#    Build time for alpine: 225.998
#    [OK] alpine
#    Build time for arch: 174.521
#    [OK] arch
#    Build time for debian: 12.693
#    [OK] debian
#    Build time for fedora: 289.985
#    [OK] fedora
#    Build time for opensuse: 232.167
#    [OK] opensuse
#    Build time for ubuntu: 8.336
#    [OK] ubuntu
# 
CONTAINER_ENGINE="podman"
BUILD_OPTS=
DISTROLIST="alpine arch debian fedora opensuse ubuntu"
OK="\e[0;32mOK\e[m"
BAD="\e[0;31mFailed!\e[m"
LOGFILE="/dev/null"

build_one() (
    local distro="${1}"
    TIMEFORMAT='%R'
    printf $"Build time for %s: " "${distro}" 
    $(time ${CONTAINER_ENGINE} build ${BUILD_OPTS}  -f=work/Dockerfile.$distro -t beroset/opendss/$distro work >>"${LOGFILE}" 2>&1 )
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
    ${CONTAINER_ENGINE} run --rm -v "${SHARED_DIR}":/mnt/host:z "beroset/opendss/${distro}" "/mnt/host/StevensonPflow-3ph.dss" 1>>${LOGFILE} 2>&1
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
    --nocache)
        echo 'Testing with no-cache option'
        BUILD_OPTS="--no-cache"
        shift
        ;;
    --logfile)
        LOGFILE="$2"
        echo "Testing with logfile = ${LOGFILE}"
        shift 2
        ;;
     --h | --he | --hel | --help)
        echo $"Usage: testall.sh [OPTION]
        --help              print this help and exit
        --podman            use Podman as the container engine
        --docker            use Docker as the container engine
        --nocache           build without using existing cached images
        --logfile log       log details to log file
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
    if (build_one "${distro}" "${BUILD_OPTS}") ; then
        test_one "${distro}" 
    else
        echo -e "[${BAD}] ${distro} failed to build"
    fi
done

