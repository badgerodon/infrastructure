#!/bin/bash

set -e

for arch in amd64 arm64v8 ; do
    docker build . -f base.dockerfile -t badgerodon/${arch}-base --build-arg ARCH=${arch}
    docker push badgerodon/${arch}-base
done
