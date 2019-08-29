FROM fedora:latest AS builder

MAINTAINER Ed Beroset <beroset@ieee.org>

RUN dnf update -y \
        && dnf install -y gsl gcc gcc-c++ libcxx-static fpc svn make

WORKDIR /tmp/
RUN svn checkout https://svn.code.sf.net/p/klusolve/code/ klusolve
RUN export LC_CTYPE=en_US.UTF8 && svn checkout https://svn.code.sf.net/p/electricdss/code/trunk/Version8/Source electric-dss
ADD Makefile Makefile
RUN make

FROM fedora:latest
WORKDIR /root/
COPY --from=builder /tmp/opendsscmd .
ADD opendss opendss
ENTRYPOINT ["/bin/bash", "/root/opendss"]
