#!/bin/bash

echo "Starting up Solr and Zookeeper 🌞 🐘🦓🦒!!!"
echo "SOLR_OPTS $SOLR_OPTS"

#an embedded ZooKeeper instance is started on the port 9983. It stars in Solr port+1000
solr start -c -h 127.0.0.1 -p 8983 -m 2g

echo "🐘🦓🦒 Checking Zookeeper on $ZK_HOST"
/opt/docker-solr/scripts/wait-for-zookeeper.sh
echo "🌞 Checking Solr"
/opt/docker-solr/scripts/wait-for-solr.sh

echo "🌞 Creating collection"
# uploads the configuration in the core-x directory and creates a collection
solr create_collection -c core-x -d core-x/ -shards 1 -replicationFactor 1

solr stop -p 8983

cat /var/solr/logs/solr.log
