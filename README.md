EPRI's [OpenDSS](https://sourceforge.net/projects/electricdss/) is software, written in Pascal, that is an electric power Distribution System Simulator (DSS).  [Docker](https://www.docker.com/) is a software virtualization program that is designed to run software in *containers*.  This project provides the few additional files to allow one to both compile and run OpenDSS in a Fedora-based Docker image.

## Prerequisites
Because it is well documented elsewhere, this document will not describe the process for installing and running Docker.  
To test if docker is running we can use

    sudo docker info

On Fedora and similar, the configuration file is `/usr/lib/systemd/system/docker.service`.

The build instructions used within this project are inspired by [these build instructions](https://sourceforge.net/p/electricdss/discussion/861976/thread/b32b74a2/5f93/attachment/EPRI_Build_OpenDSS_Linux.pdf) but on a Docker image. 

## Building OpenDSS in a Docker image
It is likely possible to build for Ubuntu, Debian and Fedora from a single script, only making minor adjustments in the script to account for differences in package dependencies and in base configuration, but this version only builds and uses a Fedora Linux distribution. To build a Docker container with the OpenDSS software, run the `create.sh` `bash` script.  Note that this build mechanism requires a recent version of Docker to support [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) and an internet connection.  This starts with a Fedora docker container, adds required build software and then downloads and builds the OpenDSS software (including the `klusolve` library) is created.  With the magic of Docker's multistage build, we can then create a new, minimal Docker container that includes just the freshly built OpenDSS software.

If everything goes successfully, the result will be a `beroset/opendss` Docker image.  Running `docker images` should verify that the `beroset/opendss` image has indeed been created.

## Using OpenDSS in a Docker image
To run OpenDSS in a Docker image requires only the previously created `beroset/opendss` image.  Because OpenDSS takes files as input and (often) creates files as output, we need to share a *volume* with Docker to allow this, since ordinarily, the Docker image has no interaction with the host system's storage.  To do this, we can use a simple `bash` script:

### 
```
#!/bin/bash
SHARED_DIR="$(pwd)/shared"
if [ ! -d "${SHARED_DIR}" ]
then
    mkdir "${SHARED_DIR}"
fi
cp "$1" "${SHARED_DIR}"
docker run --rm -v "${SHARED_DIR}":/mnt/host-dir:z -t -i beroset/opendss "/mnt/host-dir/$1"
```

This uses the Docker image as an executable and passes a file to OpenDSS.  If the project needs multiple files, all of them should be placed in the shared directory.

## Example
The [`StevensonPflow-3ph.dss`](http://svn.code.sf.net/p/electricdss/code/trunk/Distrib/Examples/Stevenson/StevensonPflow-3ph.dss) file creates a number of output files which contain solutions to various aspects of the circuit.  

If you've successfully built OpenDSS in a Docker image as described above, you can then try this simple test by running `example.sh` from the same directory as this code and documentation exists.  That is, you'd simply write:

    ./create.sh
    ./example.sh StevensonPflow-3ph.dss

The result will be three new files in the `shared` directory:

    opendss.ini
    result.tar.gz
    StevensonPflow-3ph.dss

The `opendss.ini` file contains user preferences and history for the OpenDSS software, however none of them are particularly useful for the Docker version.

## Interactive session in Docker container
Another way to run the software is to start in a `bash` shell.  A simple way to do this is:

    docker run --rm -itv "$(pwd)/shared":/mnt/host-dir:z --entrypoint=/bin/bash beroset/opendss -i

As before, the `shared` subdirectory under the host's (your *real* computer's) current working directory is mapped to `/mnt/host-dir` in the virtual Fedora machine.  The result is that you may `cd /mnt/host-dir` to get to the shared directory and run OpenDSS (the actual command is `opendsscmd`) or whatever other software the shell would normally provide.  Note that because this is a command-line version only, it does **not** support OpenDSS's GUI, nor the `Plot` command.
