#!/bin/bash
set -exuo pipefail
IFS=$'\n\t'

if [ -z "$CONSUL_VERSION" ] ; then
  echo "CONSUL_VERSION is required"
  exit 1
fi

if [ -z "$CONSUL_IPS" ] ; then
  echo "$CONSUL_IPS is required"
  exit 1
fi

if [ -z "$ARCH" ] ; then
  echo "ARCH is required"
  exit 1
fi

PRIVATE_IP="$(ip -o -4 addr show | grep -v docker | grep global | awk -F '[ /]+' '{print $4}')"

echo "[install] installing consul"
cd /tmp || exit
curl -O -L "https://releases.hashicorp.com/consul/$CONSUL_VERSION/consul_${CONSUL_VERSION}_linux_${ARCH}.zip"
unzip -o "consul_${CONSUL_VERSION}_linux_${ARCH}.zip"
mv consul /usr/bin/consul
rm "consul_${CONSUL_VERSION}_linux_${ARCH}.zip"

cat <<EOF > /etc/systemd/system/consul.service
[Unit]
Description=consul
[Service]
ExecStart=/usr/bin/consul agent \
  -data-dir="/tmp/consul-data" \
  -bind=${PRIVATE_IP} \
  $(echo "$CONSUL_IPS" | tr ',' '\n' | xargs -I{} echo '-retry-join={}' | xargs echo)
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
