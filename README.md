EPRI's OpenDSS is software, written in Pascal, that is an electric power Distribution System Simulator (DSS).  Docker is a software virtualization program that is designed to run software in *containers*.  This project provides the few additional files to allow one to both compile and run OpenDSS in a Fedora-based Docker image.

## Prerequisites
Because it is well documented elsewhere, this documnt will not describe the process for installing and running Docker.  
To test if docker is running we can use

    sudo docker info

On Fedora and similar, the configuration file is `/usr/lib/systemd/system/docker.service`.

The build instructions used within this project are inspired by [these build instructions](https://sourceforge.net/p/electricdss/discussion/861976/thread/b32b74a2/5f93/attachment/EPRI_Build_OpenDSS_Linux.pdf) but on a Docker image. 

## Building OpenDSS in a Docker image
It is likely possible to build for Ubuntu, Debian and Fedora from a single script, only making minor adjustments in the script to account for differences in package dependencies and in base configuration, but this version only builds and uses a Fedora Linux distribution. To build the `opendsscmd` software, run the `create.sh` `bash` script.  Note that this will required three files ans an internet connection.  The files are the `Dockerfile` to create the build container, a `Makefile` to create both the `klusolve` library and the `opendss` executable.  

First the Docker image is built to contain all of the appropriate tools.  Next, the OpenDSS software is created.  Because it is statically linked, the `opendsscmd` executable requires no special libraries once it is built.

If everything goes successfully, the result will be a `work` directory created and the single file `opendsscmd` will exist within it.

## Using OpenDSS is a Docker image
To run OpenDSS in a Docker image requires only the previously created `opendsscmd`.  One way to do this would be to create a separate Fedora-based Docker container and install `opendsscmd` into it.  Another way to do it is to leave the `opendsscmd` file in the location built in the previous step and run a Fedora-based Docker image while sharing the directory and using a `bash` shell to interact with the program.

## Example
TODO: create example here

