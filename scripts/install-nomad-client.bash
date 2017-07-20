#!/bin/bash

export NOMAD_VERSION=0.5.6

echo "[install] installing nomad"
cd /tmp || exit
curl -O -L https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
mv nomad /usr/bin/nomad
rm nomad_${NOMAD_VERSION}_linux_amd64.zip

mkdir -p /etc/nomad
mkdir -p /tmp/nomad
cat <<EOF > /etc/nomad/server.hcl
data_dir  = "/tmp/nomad"
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
