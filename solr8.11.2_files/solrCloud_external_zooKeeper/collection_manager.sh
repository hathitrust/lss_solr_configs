#!/bin/bash

SOLR_HOST="http://localhost:8983"

echo "Creating collection"
curl "$SOLR_HOST/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"

echo "Indexing documents"
curl "$SOLR_HOST/solr/core-x/update?commit=true" --data-binary @/var/solr/data/core-data.json -H 'Content-type:application/json'
