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
DESTINATION="/out/badgerodon-www_${VERSION}_linux_${ARCH}.tar.xz"
if [ -f "${DESTINATION}" ] ; then
    exit 0
fi

cd /tmp
env GOROOT=/root/go-tip /root/go-tip/bin/go build -o badgerodon-www github.com/badgerodon/www
cp -r /root/src/github.com/badgerodon/www/assets /tmp/assets
cp -r /root/src/github.com/badgerodon/www/tpl /tmp/tpl
tar -cJf "${DESTINATION}" badgerodon-www assets tpl
