#!/usr/bin/env bash

set -e

git clone https://github.com/golang/go.git --branch master --single-branch  # ee392ac10c7bed0ef1984dbb421491ca7b18e190
cd go/src && env GOROOT_BOOTSTRAP=/usr/lib/go ./bootstrap.bash
mv go-*-bootstrap /root/go-tip
