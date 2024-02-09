#!/bin/bash

host="http://127.0.0.1:8983"

echo "Indexing documents"
#curl "$host/solr/core-x/update?commit=true" --data-binary @solr_json_documents/core-data.json -H 'Content-type:application/json'

for file in var/solr/data/data_sample/*.xml
  do
      echo "Indexing $file 🌞!!!"
      curl "http://$SOLR_HOST/solr/core-x/update?commit=true" -H "Content-Type: text/xml" --data-binary @$file
  done

