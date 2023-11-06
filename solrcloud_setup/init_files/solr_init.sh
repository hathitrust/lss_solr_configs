#!/bin/bash

echo "Starting up Solr and Zookeeper 🌞 🐘🦓🦒!!!"

#export SOLR_HOST=127.0.0.1

echo "SOLR_OPTS $SOLR_OPTS"

#an embedded ZooKeeper instance is started on the port 9983. It stars in Solr port+1000
solr start -c -h 127.0.0.1 -p 8983 -m 2g

# Need to set this AFTER starting solr - otherwise it expects we have one
# already running..
#export ZK_HOST="127.0.0.1:9983"

echo "🐘🦓🦒 Checking Zookeeper on $ZK_HOST"
/opt/docker-solr/scripts/wait-for-zookeeper.sh
echo "🌞 Checking Solr"
/opt/docker-solr/scripts/wait-for-solr.sh

# uploads the configuration in the core-x directory and creates a collection
solr create_collection -c core-x -d _default #-d core-x/ -shards 1 -replicationFactor 1

cat /var/solr/logs/solr.log

#host="http://127.0.0.1:8983"

#echo $PWD
#echo "Indexing documents"
#curl -X POST "$host/solr/core-x/update?commit=true" --data-binary @var/solr/data/solr_json_documents/core-data.json -H 'Content-type:application/json'

#echo $PWD
# uploads the configuration in the core-x directory
#solr zk upconfig -z  127.0.0.1:9983 -n core-x -d core-x/
# Index some data...
