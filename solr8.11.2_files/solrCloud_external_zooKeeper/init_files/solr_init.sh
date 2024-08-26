#!/bin/bash

# A ZooKeeper Command Line Interface (CLI) script is used to interact directly with Solr configuration files stored in ZooKeeper.
# The upconfig command is used to upload the core configuration to ZooKeeper, this way we ensure that all collections
# using that configuration (throughout the Cloud, on all the servers) have that specific config.
# So you only need to upload it once, on one server.

# Debugging: Check if security.json exists
if [ -f /opt/solr/security.json ]; then
  echo "✅ security.json found at /opt/solr/security.json"

  echo "ZK_HOST is set to $ZK_HOST"
  echo "🐘🦓🦒 Setting up Solr Authentication"
  # Copy security.json to ZooKeeper
  # We do not need to pass -z $ZK_HOST because we set up the environment variable ZK_HOST in the Dockerfile
  solr zk cp /opt/solr/security.json zk:security.json

  # Debugging: Check the result of the copy command
  if [ $? -eq 0 ]; then
    echo "✅ security.json successfully copied to ZooKeeper"
  else
    echo "❌ Failed to copy security.json to ZooKeeper"
    exit 1
  fi
else
  echo "security.json not found at /opt/solr/security.json"
  exit 1
fi

# runs docker entry-point.sh and whatever is in command
exec /opt/docker-solr/scripts/docker-entrypoint.sh "$@"