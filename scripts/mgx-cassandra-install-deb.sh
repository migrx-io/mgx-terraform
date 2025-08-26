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

CURRENT_CLUSTER=$(grep -E '^cluster_name:' /etc/cassandra/cassandra.yaml | awk -F': ' '{print $2}' | tr -d '"')
if [ "$CURRENT_CLUSTER" != "Migrx" ]; then
    rm -rf /var/lib/cassandra/data/*
fi

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

FIRST_SEED=$(echo "${CASS_RPC_SEEDS}" | cut -d',' -f1)
FIRST_SEED_IP="${FIRST_SEED%%:*}"
TARGET=3

if [ "${CASS_RPC_ADDR}" = "${FIRST_SEED_IP}" ]; then

    # wait 3 nodes is up before run
    while true; do
        cnt=$(nodetool status | grep '^UN' | wc -l)
        if [ "$cnt" -ge "$TARGET" ]; then
            echo "✅ $cnt nodes are up."
            break
        else
            echo "Currently $cnt nodes up. Waiting..."
            sleep 5
        fi
    done
    
    if cqlsh -u "${CASS_USER}" -p "${CASS_PASSWD}" ${CASS_RPC_ADDR} -e "SHOW HOST" >/dev/null 2>&1; then
    	echo "User ${CASS_USER} already works, skipping bootstrap."
    else

	    echo "Waiting for Cassandra to accept auth..."
	    until cqlsh -u cassandra -p cassandra ${CASS_RPC_ADDR} -e "SHOW HOST" >/dev/null 2>&1; do
		sleep 5
	    done

	    cqlsh -u cassandra -p cassandra ${CASS_RPC_ADDR} -e  "ALTER KEYSPACE \"system_auth\" WITH REPLICATION = {'class' : 'NetworkTopologyStrategy', 'dc1' : 3};"

	    cqlsh -u cassandra -p cassandra ${CASS_RPC_ADDR} -e "CREATE ROLE ${CASS_USER} WITH PASSWORD = '${CASS_PASSWD}' AND SUPERUSER = true AND LOGIN = true;"
		
	    cqlsh -u ${CASS_USER} -p ${CASS_PASSWD} ${CASS_RPC_ADDR} -e "ALTER ROLE cassandra WITH PASSWORD='${CASS_PASSWD}' AND SUPERUSER=false;"

        # install schema
        apt install -t migrx -y mgx-schema
        cd /opt/mgx-schema
        cqlsh -u ${CASS_USER} -p ${CASS_PASSWD} ${CASS_RPC_ADDR} -e 'DROP KEYSPACE IF EXISTS dc1;'
        ${PYENV}/cassandra-migrate -y -m prod -c dc1.yaml -u ${CASS_USER} -P ${CASS_PASSWD} -H ${CASS_RPC_ADDR} migrate
        apt remove -y mgx-schema
        cd -
        rm -rf /opt/mgx-schema

    fi

else
    echo "This is not the first seed (${CASS_RPC_ADDR}), skipping auth + replication setup."
fi
