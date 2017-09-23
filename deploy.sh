#!/bin/bash

set -e

. ./scripts/colors.bash

trap 'echo -e "$COL_RESET"' EXIT

# ARTIFACTS
echo -e "[DEPLOY] uploading artifacts $COL_GREY"
ssh root@m1.badgerodon.com "mkdir -p /opt/artifacts"
rsync \
    --archive \
    --progress \
    --include '*amd64*' \
    --checksum \
    --delete \
    "$HOME/badgerodon/artifacts/" \
    root@m1.badgerodon.com:/opt/artifacts/
echo -e "$COL_RESET"

# CONFIG
echo -e "[DEPLOY] updating config $COL_GREY"
rsync \
    --archive \
    --progress \
    --recursive \
    --checksum \
    ./prod/etc/ \
    root@m1.badgerodon.com:/etc/
ssh root@m1.badgerodon.com "systemctl daemon-reload"
echo -e "$COL_RESET"

# SCRIPTS
echo -e "[DEPLOY] installing $COL_GREY"
rsync \
    --archive \
    --progress \
    --checksum \
    ./scripts/ \
    root@m1.badgerodon.com:/tmp
ssh root@m1.badgerodon.com "chmod +x /tmp/install-app.bash && env APP=traefik ARCH=amd64 /tmp/install-app.bash"
ssh root@m1.badgerodon.com "chmod +x /tmp/install-app.bash && env APP=badgerodon-www ARCH=amd64 /tmp/install-app.bash"
echo -e "$COL_RESET"

