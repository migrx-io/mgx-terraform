#!/bin/bash

echo ""
echo ""
echo "    ____ ____ ______  __       _________  ________  "                     
echo "   / __  __  / / _/ |/_/__ ___/ ___/  __\/ __/  _ \ "                     
echo "  / / / / / / /_/ />  </_____/ /__/ /_/ / /  /  __/ "                     
echo " /_/ /_/ /_/\__, /_/|_|      \___/\____/_/   \___/  "                     
echo "           /____/                                   "                     
echo ""                                                      
echo "     Bootstrap Scripts                              "
echo ""
echo ""

echo "STEP 1. Create DEB repo.."
echo ""

echo "deb [trusted=yes] https://repo.migrx.io/DEBS/ migrx main" | tee /etc/apt/sources.list.d/migrx.list
apt-get update

echo "STEP 2. Install packages.."
echo ""

apt install -y sqlite cron arping
apt install -y libev-dev

apt install -t migrx -y erlang 
apt install -t migrx -y python3e

apt install -t migrx -y mgx-pyenv3

apt install -t migrx -y mgx-core 
apt install -t migrx -y mgx-gateway-api
apt install -t migrx -y mgx-cli
apt install -t migrx -y mgx-schema

# add grants to group
echo "STEP 3. Configure host.."

if grep -q mgx-core /etc/sudoers; then
        echo "already configured.."
    else
        echo "%mgx-core     ALL=(ALL)       NOPASSWD:    /opt/mgx-s3backer/scripts/mgx-s3backer, /usr/sbin/fstrim, /usr/sbin/mdadm, /usr/bin/mount, /usr/bin/umount, /usr/sbin/blkid, /usr/sbin/mkfs.ext4, /usr/sbin/nvme, /usr/bin/kill, /usr/bin/systemctl, /usr/sbin/arping, /usr/bin/apt, /usr/bin/apt-cache, /usr/sbin/ip" >> /etc/sudoers

fi

# Run core
# systemctl start mgx-core
# systemctl start mgx-gateway-api
