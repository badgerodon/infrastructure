#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

apt-get update -y
apt-get install -y \
    unzip \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

apt-get install -y docker.io
systemctl enable docker
systemctl start docker

