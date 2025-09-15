# Plugins

# wait while core up
echo "Waiting for Core to be ready on port ${MGX_PORT}..."
until nc -z ${CASS_RPC_ADDR} ${MGX_PORT}; do
    sleep 2
done

# install plugins
apt install -t migrx -y mgx-plgn-aaa
apt install -t migrx -y mgx-plgn-notif
apt install -t migrx -y mgx-plgn-services
apt install -t migrx -y mgx-plgn-cache
apt install -t migrx -y mgx-plgn-storage
