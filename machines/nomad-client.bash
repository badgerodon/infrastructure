#!/bin/bash

# In User Data do:

# #!/bin/bash
# export NOMAD_VERSION=0.5.6
# curl https://raw.githubusercontent.com/badgerodon/infrastructure/master/machines/nomad-client.bash | sudo -E /bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root"
  exit 1
fi

apt-get install -y curl unzip

CONSUL_IPS=$(gcloud compute instances list --format='value[separator=","](name,networkInterfaces[0].networkIP)' | grep consul-group | cut -d, -f2 | xargs echo)

echo "[install] installing consul"
cd /tmp
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
  $(echo $CONSUL_IPS | tr ' ' '\n' | xargs -I{} echo "-join {}" | xargs echo)
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo "[install] starting consul"
systemctl daemon-reload 
systemctl enable consul
systemctl start consul


if [ -z "${NOMAD_VERSION}" ] ; then
  echo "NOMAD_VERSION is required"
  exit 1
fi

echo "[install] installing nomad"
cd /tmp
curl -O -L https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
mv nomad /usr/bin/nomad
rm nomad_${NOMAD_VERSION}_linux_amd64.zip

mkdir -p /etc/nomad
mkdir -p /var/lib/nomad
cat <<EOF > /etc/nomad/server.hcl
data_dir  = "/var/lib/nomad"
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
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF

echo "[install] starting nomad"
systemctl daemon-reload 
systemctl enable nomad
systemctl start nomad
