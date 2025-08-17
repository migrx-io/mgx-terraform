echo " Cassandra Installer"
echo ""

echo "STEP 1. Install packages.."
echo ""

curl -o /etc/apt/keyrings/apache-cassandra.asc https://downloads.apache.org/cassandra/KEYS
echo "deb [signed-by=/etc/apt/keyrings/apache-cassandra.asc] https://debian.cassandra.apache.org 41x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list
apt-get update
apt install -y cassandra 

echo "STEP 2. Clear data.."
echo ""

# clear data if exists

rm -rf /var/lib/cassandra/commitlog/*
rm -rf /var/lib/cassandra/data/*
rm -rf /var/lib/cassandra/hints/*
rm -rf /var/lib/cassandra/saved_caches/*

echo "STEP 3. Configurate.."
echo ""

# set cluster name
sed -i "s/cluster_name:.*/cluster_name: Migrx/g" /etc/cassandra/cassandra.yaml

# set snitch type
sed -i "s/endpoint_snitch:.*/endpoint_snitch: GossipingPropertyFileSnitch/g" /etc/cassandra/cassandra.yaml

# set authtorizer
sed -i "s/authenticator:.*/authenticator: PasswordAuthenticator/g" /etc/cassandra/cassandra.yaml


# set addr
sed -i "s/listen_address:.*/listen_address: ${CASS_RPC_ADDR}/g" /etc/cassandra/cassandra.yaml
sed -i "s/rpc_address:.*/rpc_address: ${CASS_RPC_ADDR}/g" /etc/cassandra/cassandra.yaml
sed -i "s/127.0.0.1:7000/${CASS_RPC_ADDR}:7000/g" /etc/cassandra/cassandra.yaml
sed -i "s/127.0.0.1:7000/${CASS_RPC_ADDR}:7000/g" /etc/cassandra/cassandra.yaml
sed -i "s/^\(\s*-\s*seeds:\s*\).*/\1\"${CASS_RPC_SEEDS}\"/" /etc/cassandra/cassandra.yaml

systemctl enable cassandra
systemctl restart cassandra

# wait while it up
echo "Waiting for Cassandra to be ready on port 9042..."
until nc -z ${CASS_RPC_ADDR} 9042; do
    sleep 2
done

cqlsh -u cassandra -p cassandra ${CASS_RPC_ADDR} -e  "ALTER KEYSPACE \"system_auth\" WITH REPLICATION = {'class' : 'NetworkTopologyStrategy', 'dc1' : 3};"

cqlsh -u cassandra -p cassandra ${CASS_RPC_ADDR} -e "CREATE ROLE ${CASS_USER} WITH PASSWORD = '${CASS_PASSWD}' AND SUPERUSER = true AND LOGIN = true;"
    
cqlsh -u $CASS_USER -p $CASS_PASSWD ${CASS_RPC_ADDR} -e "ALTER ROLE cassandra WITH PASSWORD='${CASS_PASSWD}' AND SUPERUSER=false;"
