#!/bin/bash

set -ex

OUTDIR="$HOME/badgerodon/artifacts"
ARCHES="amd64 arm64"
APPS="badgerodon-www caddy"

mkdir -p "$OUTDIR"

# build the base images
# docker build . -f "base.dockerfile" -t "base-arm64" --build-arg "SOURCE=owlab/alpine-arm64" --build-arg "VERSION=v3.5"
# docker build . -f "base.dockerfile" -t "base-amd64" --build-arg "SOURCE=alpine" --build-arg "VERSION=3.5"

# build all the apps
# for arch in $ARCHES ; do
#     for app in $APPS ; do
#         docker build . \
#             -f "${app}.dockerfile" \
#             -t "${app}-${arch}" \
#             --build-arg "ARCH=${arch}" \
#             --volume "/root/src/github.com/badgerodon:$GOPATH/src/github.com/badgerodon"
#         # extract the archive
#         docker create --name extract "${app}-${arch}:latest"
#         docker cp "extract:/tmp/${app}.tar.xz" "${OUTDIR}/${app}-${arch}.tar.xz"
#         docker rm -f extract
#     done
# done

arch="amd64"
app="badgerodon-www"
pushd "$GOPATH/src/github.com/badgerodon/www"
env GOOS=linux GOARCH=amd64 go build -i -o badgerodon-www
tar -czf "${OUTDIR}/${app}-${arch}.tar.gz" badgerodon-www assets tpl
rm badgerodon-www
popd

arch="amd64"
app="traefik"
mkdir -p /tmp/traefik-working
pushd "/tmp/traefik-working"
if [ ! -f traefik ] ; then
    curl -L -o traefik "https://github.com/containous/traefik/releases/download/v1.3.8/traefik_linux-${arch}"
fi
chmod +x traefik
tar -czf "${OUTDIR}/${app}-${arch}.tar.gz" traefik
popd
