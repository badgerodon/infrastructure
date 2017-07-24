ARG ARCH
FROM base-${ARCH}:latest

ARG ARCH
WORKDIR /tmp
RUN curl \
    --silent \
    --show-error \
    --fail \
    --location \
    --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" \
    -o - \
    https://github.com/mholt/caddy/releases/download/v0.10.4/caddy_v0.10.4_linux_$ARCH.tar.gz \
    | tar -xz caddy
RUN tar -cJf /tmp/caddy.tar.xz caddy
