#!/bin/bash

set -ex

OUTDIR="$HOME/badgerodon/artifacts"
ARCHES="amd64 arm64"
APPS="badgerodon-www caddy"

mkdir -p "$OUTDIR"

# build the base images
docker build . -f "base.dockerfile" -t "base-arm64" --build-arg "SOURCE=owlab/alpine-arm64" --build-arg "VERSION=v3.5"
docker build . -f "base.dockerfile" -t "base-amd64" --build-arg "SOURCE=alpine" --build-arg "VERSION=3.5"

# build all the apps
for arch in $ARCHES ; do
    for app in $APPS ; do
        docker build . \
            -f "${app}.dockerfile" \
            -t "${app}-${arch}" \
            --build-arg "ARCH=${arch}" \
            --volume "/root/src/github.com/badgerodon:$GOPATH/src/github.com/badgerodon"
        # extract the archive
        docker create --name extract "${app}-${arch}:latest"
        docker cp "extract:/tmp/${app}.tar.xz" "${OUTDIR}/${app}-${arch}.tar.xz"
        docker rm -f extract
    done
done
