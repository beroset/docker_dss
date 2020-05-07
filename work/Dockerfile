FROM fedora:30 AS builder

LABEL maintainer="Ed Beroset <beroset@ieee.org>"

WORKDIR /tmp/
RUN mkdir -p epri
RUN dnf update -y && \
    dnf install -y gsl gcc gcc-c++ libcxx-static fpc svn make git cmake
RUN svn checkout https://svn.code.sf.net/p/klusolve/code/ KLUSolve
RUN git clone https://github.com/pnnl/linenoise-ng.git
WORKDIR /tmp/epri/
RUN export LC_CTYPE=en_US.UTF8 && svn checkout https://svn.code.sf.net/p/electricdss/code/trunk/Version7/Source electric-dss

WORKDIR /tmp/
COPY Makefile Makefile
RUN make

FROM fedora:30
WORKDIR /root/
COPY --from=builder /tmp/opendsscmd .
COPY --from=builder /tmp/linenoise-ng/build/liblinenoise.so /lib64
COPY opendss opendss
ENTRYPOINT ["/bin/sh", "/root/opendss"]
