FROM fedora:30 AS builder

LABEL maintainer="Ed Beroset <beroset@ieee.org>"

RUN dnf update -y \
        && dnf install -y gsl gcc gcc-c++ libcxx-static fpc svn make

WORKDIR /tmp/
RUN svn checkout https://svn.code.sf.net/p/klusolve/code/ klusolve
RUN export LC_CTYPE=en_US.UTF8 && svn checkout https://svn.code.sf.net/p/electricdss/code/trunk/Version8/Source electric-dss
COPY Makefile Makefile
RUN make

FROM fedora:30
WORKDIR /root/
COPY --from=builder /tmp/opendsscmd .
COPY opendss opendss
ENTRYPOINT ["/bin/bash", "/root/opendss"]
