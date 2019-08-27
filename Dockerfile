FROM fedora:latest

MAINTAINER Ed Beroset <beroset@ieee.org>

RUN dnf update -y \
        && dnf install -y gsl gcc gcc-c++ libcxx-static fpc svn make

WORKDIR /tmp
RUN svn checkout https://svn.code.sf.net/p/klusolve/code/ klusolve
RUN export LC_CTYPE=en_US.UTF8 && svn checkout https://svn.code.sf.net/p/electricdss/code/trunk/Version8/Source electric-dss
ADD Makefile /tmp/Makefile
#RUN cd dlusolve && mkdir Lib && make all && cd Test && bash run_concat.sh
#RUN cd electric-dss/Version8/Source/CMD_Lazz/CMD && mkdir ../units && cp ../../CommandLine/OpenDSS.res opendsscmd.res
