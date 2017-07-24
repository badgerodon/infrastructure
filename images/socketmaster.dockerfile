ARG ARCH
FROM base-${ARCH}:latest

WORKDIR /tmp
ENV GOPATH /root
RUN go get github.com/badgerodon/socketmaster
RUN cp /root/bin/socketmaster /tmp/socketmaster
RUN tar -cJf /tmp/socketmaster.tar.xz socketmaster
