#!/bin/bash

set -ex

if [ -z "$APP" ] ; then
    echo "APP is required"
    exit 1
fi
if [ -z "$ARCH" ] ; then
    echo "ARCH is required"
    exit 1
fi

ARTIFACT="/opt/artifacts/${APP}-${ARCH}.tar.xz"
VERSION="$(shasum "${ARTIFACT}" | cut -d ' ' -f 1)"

DESTINATION="/opt/releases/${APP}/${VERSION}"
if [ ! -d "${DESTINATION}" ] ; then
    echo "[INSTALL] stopping ${APP}"
    systemctl stop "${APP}" || true

    echo "[INSTALL] extracting ${ARTIFACT} to ${DESTINATION}}"
    (mkdir -p "${DESTINATION}" && cd "${DESTINATION}" && tar -xJf "${ARTIFACT}")

    echo "[INSTALL] updating symlink for ${APP}"
    ln -sfn "${DESTINATION}" "/opt/${APP}"
fi

echo "[INSTALL] starting ${APP}"
systemctl enable "${APP}"
systemctl start "${APP}"
