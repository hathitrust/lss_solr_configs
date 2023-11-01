#!/bin/bash
export $(grep -v '^#' env.example | xargs -d '\n')

#echo "SOLR variables"
#export user=solr
#export password=SolrRocks
#export host="http://localhost:8983"

echo "Creating collection"
curl -u $user:$password "$host/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"

echo "Indexing documents"
curl -u $user:$password "$host/solr/core-x/update?commit=true" --data-binary @solr_json_documents/core-data.json -H 'Content-type:application/json'
