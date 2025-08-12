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

# system conf
#
# ulimit -n 1000000
# 
# sysctl -w vm.swappiness=60 # 10
# sysctl -w vm.vfs_cache_pressure=400  # 10000
# sysctl -w vm.dirty_ratio=40 # 20
# sysctl -w vm.dirty_background_ratio=1
# sysctl -w vm.dirty_writeback_centisecs=500
# sysctl -w vm.dirty_expire_centisecs=30000
# sysctl -w kernel.panic=10
# sysctl -w fs.file-max=1000000
# sysctl -w net.core.netdev_max_backlog=10000
# sysctl -w net.core.somaxconn=65535
# sysctl -w net.ipv4.tcp_syncookies=1
# sysctl -w net.ipv4.tcp_max_syn_backlog=262144
# sysctl -w net.ipv4.tcp_max_tw_buckets=720000
# sysctl -w net.ipv4.tcp_tw_recycle=1
# sysctl -w net.ipv4.tcp_timestamps=1
# sysctl -w net.ipv4.tcp_tw_reuse=1
# sysctl -w net.ipv4.tcp_fin_timeout=30
# sysctl -w net.ipv4.tcp_keepalive_time=1800
# sysctl -w net.ipv4.tcp_keepalive_probes=7
# sysctl -w net.ipv4.tcp_keepalive_intvl=30
# sysctl -w net.core.wmem_max=33554432
# sysctl -w net.core.rmem_max=33554432
# sysctl -w net.core.rmem_default=8388608
# sysctl -w net.core.wmem_default=4194394
# sysctl -w net.ipv4.tcp_rmem="4096 8388608 16777216"
# sysctl -w net.ipv4.tcp_wmem="4096 4194394 16777216"


echo "STEP 1. Create DEB repo.."
echo ""

echo "deb [trusted=yes] https://repo.migrx.io/DEBS/ migrx main" | tee /etc/apt/sources.list.d/migrx.list
apt-get update     

echo "STEP 2. Install packages.."
echo ""

apt install -y sqlite cron arping

apt install -t migrx -y erlang 
apt install -t migrx -y python3e

apt install -t migrx -y mgx-pyenv3

apt install -t migrx -y mgx-core 
apt install -t migrx -y mgx-gateway-api
apt install -t migrx -y mgx-cli

# add grants to group
echo "STEP 3. Configure host.."

if grep -q mgx-core /etc/sudoers; then
        echo "already configured.."
    else
        echo "%mgx-core     ALL=(ALL)       NOPASSWD:    /usr/bin/kill, /usr/bin/systemctl, /usr/sbin/arping, /usr/bin/apt, /usr/bin/apt-cache, /usr/sbin/ip" >> /etc/sudoers

fi

if grep -q PYENV /etc/mgx-env; then
        echo "already configured.."
    else
        echo 'LOGLEVEL=INFO' >> /etc/mgx-env
        echo 'PYENV=/opt/mgx-pyenv3/bin' >> /etc/mgx-env
        echo 'MGX_GW_PORT=8082' >> /etc/mgx-env
        echo 'MGX_PORT=8081' >> /etc/mgx-env
        echo 'MGX_GW_IS_TLS=n' >> /etc/mgx-env
        echo 'MGX_IS_TLS=n' >> /etc/mgx-env
fi

# Run core
# systemctl start mgx-core
# systemctl start mgx-gateway-api
