#!/bin/bash
export $(grep -v '^#' .env | xargs -d '\n')

echo "Generating collections!!"

#cd conf


#rm core-x.zip


#zip -r ../core-x.zip .

#cd ..

echo "SOLR variables"
export user=solr
export password=SolrRocks
export host="http://localhost:8983"

#curl -u solr:SolrRocks -X DELETE "http://localhost:8983/api/cluster/configs/core-x"
#curl -u solr:SolrRocks -X PUT --header "Content-Type:application/octet-stream" --data-binary @core-x.zip "http://localhost:8983/api/cluster/configs/core-x"

#curl -u $user:$password "$host/solr/admin/collections?action=DELETE&name=core-x"
#curl -u $user:$password "$host/solr/admin/collections?action=CREATE&name=core-x&numShards=1&collection.configName=core-x"

#Creating collection
curl -u solr:SolrRocks "http://localhost:8983/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"

#Indexing documents


############

#curl -u solr:SolrRocks -X DELETE "http://localhost:8983/api/cluster/configs/core-x"
#curl -u solr:SolrRocks -X PUT --header "Content-Type:application/octet-stream" --data-binary @core-x.zip "http://localhost:8983/api/cluster/configs/core-x"
