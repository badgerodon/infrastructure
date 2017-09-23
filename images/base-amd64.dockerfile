ARG ARCH
FROM ${ARCH}/golang:1.9

ENV GOPATH=/root
VOLUME "/root/pkg"
VOLUME "/root/src"
VOLUME "/out"
CMD ["/bin/bash"]

WORKDIR "/root"
