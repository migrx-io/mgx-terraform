#!/bin/bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
MGX_VAR_DIR=/var/lib/migrx
PY=/opt/mgx-pyenv3/bin/python
MDADM_CONF_FILE="/etc/mdadm/mdadm.conf"

# 0. Wait while NAT will be reachable
sleep 30

while true; do
  echo "Checking repo availability via NAT..."
  if curl -s -o /dev/null -w "%{http_code}" https://repo.migrx.io | grep -q "404"; then
    echo "Repo reachable, NAT is ready."
    break
  fi
  echo "Repo not reachable yet, retrying in 10s..."
  sleep 10
done

# 1. install mgx-core and etc
bash -e ./mgx-bootstrap-deb.sh

# 2. Generate mgx-id and mgx-hosts
MGX_ID=$($PY ./setup-helper.py mgx-id)

echo "${MGX_ID}" > ${MGX_VAR_DIR}/mgx-id

# 3. Set all hosts for pool
$PY ./setup-helper.py mgx-hosts > ${MGX_VAR_DIR}/mgx-hosts

# 4. Set envs
$PY ./setup-helper.py mgx-env > /etc/mgx-env

# 5. Expose envs
export $(xargs < /etc/mgx-env)

# 6. Install cassandra
export CASS_RPC_SEEDS=$($PY ./setup-helper.py mgx-cass-seeds)
export CASS_NODES_COUNT=$($PY ./setup-helper.py mgx-cass-nodes-count)
bash -e ./mgx-cassandra-install-deb.sh

# 8. Install spdk deps
bash -e ./mgx-spdk-deb.sh
cp ./mgx-spdk /etc/mgx-spdk
cp ./mgx-spdk-cache /etc/mgx-spdk-cache

# 9. Start services
mkhomedir_helper mgx-core
chown mgx-core:mgx-core /etc/mgx-env
chown mgx-core:mgx-core /etc/mgx-spdk
chown mgx-core:mgx-core /etc/mgx-spdk-cache
chown mgx-core:mgx-core -R /etc/cassandra/

systemctl enable mgx-core
systemctl enable mgx-gateway-api
systemctl enable cron

systemctl enable mgx-spdk
systemctl enable mgx-spdk-cache

systemctl restart mgx-core
systemctl restart mgx-gateway-api
systemctl restart cron

systemctl restart mgx-spdk
systemctl restart mgx-spdk-cache

# 10. Install plugins 
bash -e ./mgx-plugins-deb.sh

# 11. Set nqn
echo "nqn.2014-08.org.nvmexpress:uuid:${MGX_ID}" > /etc/nvme/hostnqn

# 12. Disable mdadn auto assemble
# Add AUTO -all if not already present
if ! grep -q "^AUTO -all" "$MDADM_CONF_FILE"; then
  echo "AUTO -all" >> "$MDADM_CONF_FILE"
  echo "'AUTO -all' to $CONF_FILE"
else
  echo "'AUTO -all' already present in $CONF_FILE"
fi

# Regenerate initramfs
echo "Updating initramfs..."
update-initramfs -u

# 13. Install manifest
$PY ./setup-helper.py mgx-cluster

echo "Storage OK!"
