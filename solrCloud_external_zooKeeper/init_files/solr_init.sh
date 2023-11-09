#!/bin/bash

# A ZooKeeper Command Line Interface (CLI) script is used to interact directly with Solr configuration files stored in ZooKeeper.
# The upconfig command is used to upload the core configuration to ZooKeeper, this way we ensure that all collections
# using that configuration (throughout the Cloud, on all the servers) have that specific config.
# So you only need to upload it once, on one server.

# enables solr to start with basic auth turned on
solr zk cp /var/solr/data/security.json zk:security.json -z zoo1:2181

# uploads the configuration in the core-x directory
solr zk upconfig -z  zoo1:2181 -n core-x -d core-x/

echo "🐘🦓🦒 Checking Zookeeper on $ZK_HOST"
/opt/docker-solr/scripts/wait-for-zookeeper.sh

# runs docker entry-point.sh and whatever is in command
exec /opt/docker-solr/scripts/docker-entrypoint.sh "$@"