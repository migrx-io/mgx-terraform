#!/bin/bash
set -e 

export DEBIAN_FRONTEND=noninteractive
MGX_VAR_DIR=/var/lib/migrx
PY=/opt/mgx-pyenv3/bin/python

# 1. install mgx-core and etc
sh ./mgx-bootstrap-deb.sh

# 2. Generate mgx-id and mgx-hosts
$PY ./setup-helper.py mgx-id > ${MGX_VAR_DIR}/mgx-id

# 3. Set all hosts for pool
$PY ./setup-helper.py mgx-hosts > ${MGX_VAR_DIR}/mgx-hosts

# 4. Set envs
$PY ./setup-helper.py mgx-env > /etc/mgx-env

# 5. Expose envs
export $(xargs < /etc/mgx-env)

# 6. Install cassandra
export CASS_RPC_SEEDS=$($PY ./setup-helper.py mgx-cass-seeds)
sh ./mgx-cassandra-install-deb.sh

# 7. Start services
mkhomedir_helper mgx-core
chown mgx-core:mgx-core /etc/mgx-env
chown mgx-core:mgx-core -R /etc/cassandra/

systemctl enable mgx-core
systemctl enable mgx-gateway-api
systemctl enable cron

systemctl restart mgx-core
systemctl restart mgx-gateway-api
systemctl restart cron

echo "Storage OK!"
