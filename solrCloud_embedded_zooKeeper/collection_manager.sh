#!/bin/bash
export $(grep -v '^#' env.example | xargs -d '\n')

host="http://127.0.0.1:8983"

echo "Indexing documents"
curl -u $user:$password "$host/solr/core-x/update?commit=true" --data-binary @solr_json_documents/core-data.json -H 'Content-type:application/json'
