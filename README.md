EPRI's [OpenDSS](https://sourceforge.net/projects/electricdss/) is software, written in Pascal, that is an electric power Distribution System Simulator (DSS).  [Docker](https://www.docker.com/) is a software virtualization program that is designed to run software in *containers*.  This project provides the few additional files to allow one to both compile and run OpenDSS in a Fedora-based Docker image.

## Prerequisites
Because it is well documented elsewhere, this document will not describe the process for installing and running Docker.  
To test if docker is running we can use

    sudo docker info

On Fedora and similar, the configuration file is `/usr/lib/systemd/system/docker.service`.

The build instructions used within this project are inspired by [these build instructions](https://sourceforge.net/p/electricdss/discussion/861976/thread/b32b74a2/5f93/attachment/EPRI_Build_OpenDSS_Linux.pdf) but on a Docker image. 

## Building OpenDSS in a Docker image
It is likely possible to build for Ubuntu, Debian and Fedora from a single script, only making minor adjustments in the script to account for differences in package dependencies and in base configuration, but this version only builds and uses a Fedora Linux distribution. To build the `opendsscmd` software, run the `create.sh` `bash` script.  Note that this build mechanism require just three files and an internet connection.  The files are the `Dockerfile` to create the build container, a `Makefile` and the `create.sh` file.  This downloads the source code for and creates both the `klusolve` library and the OpenDSS executable.  

First the Docker image is built to contain all of the appropriate tools.  Next, the OpenDSS software (including the `klusolve` library) is created.  Because it is statically linked, the `opendsscmd` executable requires no special libraries once it is built.

If everything goes successfully, the result will be a `work` directory created and the single file `opendsscmd` will exist within it.

## Using OpenDSS in a Docker image
To run OpenDSS in a Docker image requires only the previously created `opendsscmd`.  One way to do this would be to create a separate Fedora-based Docker container and install `opendsscmd` into it.  Another way to do it is to leave the `opendsscmd` file in the location built in the previous step and run a Fedora-based Docker image while sharing the directory and using a `bash` shell to interact with the program.

## Example
If we have created the OpenDSS file `opendsscmd` in a `work` directory, and we have the relevant dss files in that same directory we can easily run it:

    docker run --rm -v "$(pwd)/work":/tmp/work:z -t -i docker.io/fedora:latest /tmp/work/opendsscmd /tmp/work/StevensonPflow-3ph.dss

That works, but it's not very useful.  The reason is that the [`StevensonPflow-3ph.dss`](http://svn.code.sf.net/p/electricdss/code/trunk/Distrib/Examples/Stevenson/StevensonPflow-3ph.dss) file creates a number of output files which instantly vanish when the container is shut down.  By default, the Linux version of OpenDSS attempts to open an editor `xdg-open` which is not, by default, installed in the container we're using.  So rather than having an editor open multiple files, we can instead simply copy them.  One way to do that is shown in the `test.sh` file in this repository.  It runs OpenDSS and then uses `tar` to create a compressed archive of all resulting files.  That archive, uncreatively named `result.tar.gz` is in the same read/write directory as was used for the dss file, so when the Docker container shuts down, we still have all of the results in a file.  In this case, with the `StevensonPflow-3ph.dss` file, there are five resulting text files containing the calculated results for the circuit.

If you've successfully built OpenDSS in a Docker image as described above, you can then try this simple test by running `example.sh` from the same directory as this code and documentation exists.  That is, you'd simply write:

    ./create.sh
    ./example.sh

The result will be three new files in the `work` directory:

    opendsscmd
    opendss.ini
    result.tar.gz

The `opendss.ini` file contains user preferences and history for the OpenDSS software, however none of them are particularly useful for the Docker version.

## Interactive session in Docker container
Another way to run the software is to start in a `bash` shell.  A simple way to do this is:

    docker run --rm -v "$(pwd)/work":/tmp/work:z -t -i docker.io/fedora:latest /bin/bash -i

As before, the `work` subdirectory under the host's (your *real* computer's) current working directory is mapped to `/tmp/work` in the virtual Fedora machine.  The result is that you may `cd /tmp/work` to get to the shared directory and run OpenDSS or whatever other software the shell would normally provide.  Note that because this is a command-line version only, it does **not** support OpenDSS's GUI, nor the `Plot` command.
