EPRI's [OpenDSS](https://sourceforge.net/projects/electricdss/) is software, written in Pascal, that is an electric power Distribution System Simulator (DSS).  [Docker](https://www.docker.com/) is a software virtualization program that is designed to run software in *containers*.  This project provides the few additional files to allow one to both compile and run OpenDSS in a Linux container image based on any of seven different Linux distributions.  Although the script files are configured to use [Podman](https://podman.io/), Docker can also easily be used.  

## Prerequisites
### Using Podman
Podman is a daemonless container engine and can easily be used instead of docker.  Because it does not require any special privileges, this project uses Podman, but the syntax of the Podman commands is essentially identical to Docker's so either can be used.

### Using Docker
Because it is well documented elsewhere, this document will not describe the process for installing and running Docker.  
To test if docker is running we can use

    sudo docker info

On Fedora and similar, the configuration file is `/usr/lib/systemd/system/docker.service`.

## Building OpenDSS in a container image
### The easy way
The simplest way to build a container directly using Podman is to create a repository directly from git:

    podman build git://github.com/beroset/docker_dss.git -t beroset/opendss

This creates a Debian-based image by temporarily cloning the repository.

### The hard way
The build instructions used within this project are inspired by [these build instructions](https://sourceforge.net/p/electricdss/discussion/861976/thread/b32b74a2/5f93/attachment/EPRI_Build_OpenDSS_Linux.pdf) but on a container image. 

It is possible build for container images based on many different distributions.  To build a container with the OpenDSS software, run the `create.sh` `bash` script.  Note that this build mechanism requires a recent version of Podman (or Docker) to support [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) and an internet connection.  This starts with a Debian software container, adds required build software and then downloads and install the FreePascal compiler, `fpc` and then the OpenDSS software (including the `klusolve` library) is created.  With the magic of multistage build, we can then create a new, minimal container that includes just the freshly built OpenDSS software.  This is why little effort has been expended on making the build image small, since it is essentially thrown away once the required executable has been created.

If everything goes successfully, the result will be a `beroset/opendss` container image.  Running `podman images` should verify that the `beroset/opendss` image has indeed been created.

## Different distributions
The code currently supports Fedora, Debian, Ubuntu, Arch, CentOS, OpenSUSE and Alpine distribution containers, although there are some problems with the Alpine distribution.

|base   | image size (MB) | build command | notes                 |
| ----- | ---------- | ------------- | --------------------- |
|Alpine | 12.3 | podman build -f=work/Dockerfile.alpine work | no issues |
|Arch   | 427 | podman build -f=work/Dockerfile.arch work | no issues |
|CentOS | 214 | podman build -f=work/Dockerfile.centos work | no issues |
|Debian | 86.8 | podman build -f=work/Dockerfile.debian work | no issues |
|Fedora | 185 | podman build -f=work/Dockerfile.fedora work | no issues |
|openSUSE | 112 | podman build -f=work/Dockerfile.opensuse work | no issues |
|Ubuntu | 79.3 | podman build -f=work/Dockerfile.ubuntu work | no issues |

## Using OpenDSS in a container image
To run OpenDSS in a container image requires only the previously created `beroset/opendss` image.  Because OpenDSS takes files as input and (often) creates files as output, we need to share a *volume* with the container to allow this, since ordinarily, the container image has no interaction with the host system's storage.  To do this, we can use a simple `bash` script:

### 
```
#!/bin/bash
SHARED_DIR="$(pwd)/shared"
if [ ! -d "${SHARED_DIR}" ]
then
    mkdir "${SHARED_DIR}"
fi
cp "$1" "${SHARED_DIR}"
podman run --rm -itv "${SHARED_DIR}":/mnt/host:z beroset/opendss "/mnt/host/$1"
```

This uses the container image as an executable and passes a file to OpenDSS.  If the project needs multiple files, all of them should be placed in the shared directory.

## Example
The [`StevensonPflow-3ph.dss`](http://svn.code.sf.net/p/electricdss/code/trunk/Distrib/Examples/Stevenson/StevensonPflow-3ph.dss) file creates a number of output files which contain solutions to various aspects of the circuit.  

If you've successfully built OpenDSS in a container image as described above, you can then try this simple test by running `example.sh` from the same directory as this code and documentation exists.  That is, you'd simply write:

    ./create.sh
    ./example.sh StevensonPflow-3ph.dss

The result will be six files in the `shared` directory:

    StevensonPflow-3ph.dss        
    Stevenson_Power_elem_MVA.txt  
    Stevenson_VLN_Node.Txt
    Stevenson_Power_seq_MVA.txt
    Stevenson_NodeMismatch.Txt  
    Stevenson_Convergence.TXT   

The first file is, of course, the input file and the other five are the output files which contain the requested calculations.

## Interactive session in a container
Another way to run the software is to start in a `sh` shell.  A simple way to do this is:

    podman run --rm -itv "$(pwd)/shared":/mnt/host:z --entrypoint=/bin/sh beroset/opendss -i

As before, the `shared` subdirectory under the host's (your *real* computer's) current working directory is mapped to `/mnt/host` in the virtual Debian machine.  The result is that you may `cd /mnt/host` to get to the shared directory and run OpenDSS (the actual command is `opendsscmd`) or whatever other software the shell would normally provide.  Note that because this is a command-line version only, it does **not** support OpenDSS's GUI, nor the `Plot` command.

For convenience, this is also put into a shell script `tryme.sh`.

## Testing
An overall test suite has been included within the project.  It is in the bash script `testall.sh`.  With a single command, all containers can be built and sanity-tested.  Be aware, however, that this requires an internet connection and may take considerable time - on a 3.4GHz i7 with gigabit fiber internet connection, the full test suite takes over 36 minutes to complete.

    Usage: testall.sh [OPTION]
            --help              print this help and exit
            --podman            use Podman as the container engine
            --docker            use Docker as the container engine

As shown above, the `testall.sh` program takes a single option to specify which container engine is used.  If no options are specified, Podman is used by default.
