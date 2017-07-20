#!/bin/bash

export CONSUL_VERSION=0.8.5

echo "[install] installing consul"
cd /tmp || exit
curl -O -L https://releases.hashicorp.com/consul/$CONSUL_VERSION/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
mv consul /usr/bin/consul
rm consul_${CONSUL_VERSION}_linux_amd64.zip

cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul
[Service]
ExecStart=/usr/bin/consul agent -server \
  -data-dir="/tmp/consul" \
  -bootstrap-expect 3 \
  -retry-join-gce-tag-value consul
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo "[install] starting consul"
systemctl daemon-reload
systemctl enable consul
systemctl start consul
