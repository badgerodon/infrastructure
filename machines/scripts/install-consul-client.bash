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
ExecStart=/usr/bin/consul agent \
  -data-dir="/tmp/consul" \
  -bind="$(ip -o -4 addr show | grep -v docker | grep global | awk -F '[ /]+' '{print $4}')" \
  -retry-join-gce-tag-value consul
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo "[install] starting consul"
systemctl daemon-reload
systemctl enable consul
systemctl start consul

cat <<EOF > /etc/dhcp/dhclient.conf
prepend domain-name-servers 127.0.0.1;
EOF
