FROM debian:buster AS builder

LABEL maintainer="Ed Beroset <beroset@ieee.org>"

WORKDIR /tmp/
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p epri
RUN apt-get -y update && \
    apt-get install -y subversion git make cmake g++ fpc
RUN git clone https://github.com/pnnl/linenoise-ng.git
RUN svn checkout https://svn.code.sf.net/p/klusolve/code/ KLUSolve
RUN svn checkout https://svn.code.sf.net/p/electricdss/code/trunk/Version7/Source epri/electric-dss

COPY work/remove_obsolete_agent_calls.diff .
RUN cd epri/electric-dss && \
    svn patch --non-interactive /tmp/remove_obsolete_agent_calls.diff

COPY work/Makefile Makefile
RUN make

FROM debian:buster-slim
WORKDIR /root/
RUN mkdir -p /root/Documents/OpenDSSCmd
COPY --from=builder /tmp/opendsscmd .
COPY --from=builder /tmp/linenoise-ng/build/liblinenoise.so /lib/x86_64-linux-gnu/
ENTRYPOINT ["/root/opendsscmd"]
