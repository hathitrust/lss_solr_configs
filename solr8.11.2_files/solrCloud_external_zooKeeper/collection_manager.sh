#!/bin/bash

SOLR_HOST=$1

echo "Creating collection"
curl "$SOLR_HOST/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"

