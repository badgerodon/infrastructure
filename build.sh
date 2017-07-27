#!/usr/bin/env bash

set -ex

. ./scripts/colors.bash
trap 'echo -e "$COL_RESET"' EXIT

OUTDIR="$HOME/badgerodon/artifacts"
ARCHES="amd64 arm64"

declare -A APPS
APPS['caddy']='0.10.4'
APPS['badgerodon-www']='0.0.1'

mkdir -p "$OUTDIR"

# build the base images
echo -e "[BUILD] building base docker images $COL_YELLOW"
docker build . -f "images/base.dockerfile" -t "base-amd64" --build-arg "SOURCE=alpine" --build-arg "VERSION=3.5"
docker build . -f "images/base.dockerfile" -t "base-arm64" --build-arg "SOURCE=owlab/alpine-arm64" --build-arg "VERSION=v3.5"
echo -e "$COL_RESET"

# build all the apps
for arch in $ARCHES ; do
    for app in "${!APPS[@]}" ; do
        echo -e "[BUILD] building ${app} version=${APPS[$app]} arch=${arch} $COL_YELLOW"
        docker run \
            -v "$HOME/badgerodon/pkg:/root/pkg" \
            -v "$HOME/badgerodon/src:/root/src" \
            -v "$(pwd)/build/${app}.bash:/tmp/${app}.bash" \
            -v "$OUTDIR:/out" \
            -t -i \
            "base-${arch}" \
            env "ARCH=${arch}" "VERSION=${APPS[$app]}" sh -f /tmp/${app}.bash
        echo -e "$COL_RESET"
    done
done
