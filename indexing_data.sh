#!/usr/bin/env bash

# This script is used to index the sample data into the Solr core

# Example: ./indexing_data.sh http://localhost:8983 ~/mydata data_sample.zip

solr_url="$1" #Solr URL
solr_pass="$2"
sample_data_directory="$3" #Directory where the sample data is located (XML files)
zip_file="$4" #Zip file containing the sample data

if [ -d "$sample_data_directory" ]
    then
        echo "$sample_data_directory exists"
    else
        unzip -d "$sample_data_directory" "$zip_file"

        echo "$home"
    fi


echo $SOLR_PASS
for file in "$sample_data_directory/data_sample/"*.xml
          do
              echo "Indexing $file 🌞!!!"
              curl -u admin:$solr_pass "$solr_url/solr/core-x/update?commit=true" -H "Content-Type: text/xml" --data-binary @$file
          done


