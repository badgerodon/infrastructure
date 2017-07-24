ARG ARCH
FROM base-${ARCH}:latest

WORKDIR /root/src/github.com/badgerodon/www
ENV GOPATH /root
RUN go build -o badgerodon-www .
RUN tar -cJf /tmp/badgerodon-www.tar.xz badgerodon-www assets tpl
