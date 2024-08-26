#!/bin/bash

echo "Starting up Solr and Zookeeper 🌞 🐘🦓🦒!!!"

# an embedded ZooKeeper instance is started on the port 9983. It stars in Solr port+1000
solr start -c -h 127.0.0.1 -p 8983 -m 2g

echo "🐘🦓🦒 Checking Zookeeper on $ZK_HOST"
/opt/docker-solr/scripts/wait-for-zookeeper.sh

# enables solr to start with basic auth turned on
solr zk cp /opt/solr/security.json zk:security.json

echo "🌞 Checking Solr"
/opt/docker-solr/scripts/wait-for-solr.sh

# runs docker entry-point.sh and whatever is in command
exec /opt/docker-solr/scripts/docker-entrypoint.sh "$@"

# echo "🌞 Creating collection"
# uploads the configuration in the core-x directory and creates a collection
# solr create_collection -c core-x -d core-x/ -shards 3 -replicationFactor 3

# solr stop -p 8983

# cat /var/solr/logs/solr.log