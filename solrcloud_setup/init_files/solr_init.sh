#!/bin/bash

# enables solr to start with basic auth turned on
solr zk cp /var/solr/data/security.json zk:security.json -z zoo1:2181

# uploads the configuration in the core-x directory
solr zk upconfig -z  zoo1:2181 -n core-x -d /core-x

# Link a collection to a Configset
#solr zk link-config -z zoo1:2181 -c core-x -n core-x

echo "Starting up Solr and Zookeeper!!!"

# runs docker entry-point.sh and whatever is in command
exec /opt/docker-solr/scripts/docker-entrypoint.sh "$@"

echo "SOLR variables"
export user=solr
export password=SolrRocks
export host="http://localhost:8983"

#Creating collection
#echo "Creating collection"
#curl -u solr:SolrRocks "http://localhost:8983/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"
