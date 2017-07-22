#!/bin/bash
set -exuo pipefail
IFS=$'\n\t'

if [ -z "$NOMAD_VERSION" ] ; then
  echo "CONSUL_VERSION is required"
  exit 1
fi

if [ -z "$ARCH" ] ; then
  echo "ARCH is required"
  exit 1
fi

echo "[install] installing nomad"
cd /tmp || exit
curl -O -L "https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_${ARCH}.zip"
unzip -o "nomad_${NOMAD_VERSION}_linux_${ARCH}.zip"
mv nomad /usr/bin/nomad
rm "nomad_${NOMAD_VERSION}_linux_${ARCH}.zip"

mkdir -p /etc/nomad
mkdir -p /tmp/nomad-data
cat <<EOF > /etc/nomad/server.hcl
data_dir  = "/tmp/nomad-data"
client {
  enabled = true
}
EOF

cat <<EOF > /etc/systemd/system/nomad.service
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/
[Service]
ExecStart=/usr/bin/nomad agent -config /etc/nomad
ExecReload=/bin/kill -HUP \$MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

echo "[install] starting nomad"
systemctl daemon-reload
systemctl enable nomad
systemctl start nomad
