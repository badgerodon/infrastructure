#!/bin/bash
set -x

echo "repackaging $1 to $2"

gunzip -c "$1" | xz -z > "$2"
