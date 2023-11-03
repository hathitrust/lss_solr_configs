#!/bin/bash

echo "Starting up Solr and Zookeeper 🌞 🐘🦓🦒!!!"

export SOLR_HOST=127.0.0.1

echo "SOLR_OPTS $SOLR_OPTS"
solr start -c

# Need to set this AFTER starting solr - otherwise it expects we have one
# already running..
export ZK_HOST="127.0.0.1:9983"

echo "🐘🦓🦒 Checking Zookeeper on $ZK_HOST"
/opt/docker-solr/scripts/wait-for-zookeeper.sh
echo "🌞 Checking Solr"
/opt/docker-solr/scripts/wait-for-solr.sh

# uploads the configuration in the core-x directory and creates a collection
solr create_collection -c core-x -d /core-x

cat /var/solr/logs/solr.log

# Index some data...
