#!/bin/bash

# A ZooKeeper Command Line Interface (CLI) script is used to interact directly with Solr configuration files stored in ZooKeeper.
# The upconfig command is used to upload the core configuration to ZooKeeper, this way we ensure that all collections
# using that configuration (throughout the Cloud, on all the servers) have that specific config.
# So you only need to upload it once, on one server.

# /var/solr/data isn't part of this image - Solr only creates it at first startup, as whatever user
# runs the process. So when a *fresh named volume* is mounted over that path, Docker has nothing to
# "copy up" ownership from (the path doesn't exist in any image layer) and just materializes an empty
# directory owned by root:root instead. Solr itself runs as the unprivileged "solr" user, so without a
# fix, writes under /var/solr/data (e.g. core.properties on collection create) fail with "Couldn't
# persist core properties". This image is reused across repos/deployments though, and not all of them
# start the container as root - so only attempt the chown+gosu-drop pattern when we actually are root
# (see `user: root` in this repo's docker-compose_solr9.yml). Otherwise run everything as whatever
# user the container was started as, and assume that user can already write to the volume.
#if [ "$(id -u)" = "0" ]; then
#  echo "🔧 Fixing ownership of /var/solr/data"
#  chown -R solr:solr /var/solr/data
#  SOLR_RUNNER="gosu solr"
#else
#  echo "ℹ️ Not running as root (uid $(id -u)) - skipping ownership fix, assuming /var/solr/data is already writable"
#  SOLR_RUNNER=""
#fi

# Debugging: Check if security.json exists
if [ -f /opt/solr/security.json ]; then
  echo "✅ security.json found at /opt/solr/security.json"

  echo "ZK_HOST is set to $ZK_HOST"

  # solr zk cp creates the znode and fails with NodeExistsException if it's already there.
  # ZooKeeper's data lives on a persistent volume, so this step would otherwise crash-loop the
  # container on every restart that isn't a full volume wipe - skip it once already bootstrapped.
  if solr zk ls zk:security.json > /dev/null 2>&1; then
    echo "ℹ️ security.json already present in ZooKeeper, skipping upload"
  else
    echo "🐘🦓🦒 Setting up Solr Authentication"
    # Copy security.json to ZooKeeper
    # We do not need to pass -z $ZK_HOST because we set up the environment variable ZK_HOST in the Dockerfile
    # Run as the solr user (not root) so any local files the CLI writes stay owned by solr.
    solr zk cp /opt/solr/security.json zk:security.json

    # Debugging: Check the result of the copy command
    if [ $? -eq 0 ]; then
      echo "✅ security.json successfully copied to ZooKeeper"
    else
      echo "❌ Failed to copy security.json to ZooKeeper"
      exit 1
    fi
  fi
else
  echo "security.json not found at /opt/solr/security.json"
  exit 1
fi

# runs docker entry-point.sh, dropped to the solr user via gosu only when we started as root.
# Solr 9's official image moved this script from /opt/docker-solr/scripts to /opt/solr/docker/scripts
# (verified against the real solr:9.10.1 image - it's also on $PATH there as docker-entrypoint.sh).
exec /opt/solr/docker/scripts/docker-entrypoint.sh "$@"