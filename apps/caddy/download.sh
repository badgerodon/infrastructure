#!/bin/bash
set -x

eval "$(sed 's/^/export /' "$1")"

if [ -z "$ARCH" ] ; then
  echo "ARCH is required"
  exit 1
fi

if [ -z "$CADDY_VERSION" ] ; then
  echo "CADDY_VERSION is required"
  exit 1
fi

curl --fail -L -o "$2" "https://github.com/mholt/caddy/releases/download/v${CADDY_VERSION}/caddy_v${CADDY_VERSION}_linux_${ARCH}.tar.gz"
