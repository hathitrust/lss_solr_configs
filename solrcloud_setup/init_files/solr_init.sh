#!/bin/bash

# enables solr to start with basic auth turned on
solr zk cp /var/solr/data/security.json zk:security.json -z zoo1:2181

# uploads the configuration in the authority_browse directory
solr zk upconfig -z  zoo1:2181 -n core-x -d /core-x

echo "Starting up Solr and Zookeeper!!!"

# runs docker entry-point.sh and whatever is in command
exec /opt/docker-solr/scripts/docker-entrypoint.sh "$@"