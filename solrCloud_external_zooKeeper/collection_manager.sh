#!/bin/bash
export $(grep -v '^#' env.example | xargs -d '\n')

SOLR_HOST="http://localhost:8983"
SOLR_PASSWORD=SolrRocks
SOLR_USERNAME=solr

echo "Creating collection"
curl -u $SOLR_USERNAME:$SOLR_PASSWORD "$SOLR_HOST/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"

echo "Indexing documents"
curl -u $SOLR_USERNAME:$SOLR_PASSWORD "$SOLR_HOST/solr/core-x/update?commit=true" --data-binary @/var/solr/data/core-data.json -H 'Content-type:application/json'
