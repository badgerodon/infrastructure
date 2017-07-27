#!/bin/bash

set -ex

if [ -z "${ARCH}" ] ; then
    echo "ARCH is required"
    exit 1
fi
if [ -z "${VERSION}" ] ; then
    echo "VERSION is required"
    exit 1
fi
DESTINATION="/out/caddy_${VERSION}_linux_${ARCH}.tar.xz"
if [ -f "${DESTINATION}" ] ; then
    exit 0
fi

cd /tmp
curl \
    --silent \
    --show-error \
    --fail \
    --location \
    -o - \
    "https://github.com/mholt/caddy/releases/download/v${VERSION}/caddy_v${VERSION}_linux_${ARCH}.tar.gz" \
    | tar -xz caddy
tar -cJf "${DESTINATION}" caddy
