#!/bin/bash

APP="$1"

if [ -z "$APP" ] ; then
    echo "APP is required"
    exit 1
fi

ARTIFACT="/opt/artifacts/${APP}.tar.xz"
ARTIFACT_VERSION=$(shasum )

cat <<EOF > /etc/systemd/system/caddy.service
[Unit]
Description=caddy
[Service]
ExecStart=/opt/caddy/caddy
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo "[install] starting caddy"
systemctl daemon-reload
systemctl enable caddy
systemctl start caddy
