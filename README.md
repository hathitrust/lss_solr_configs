# lss_solr_configs
Configuration files for HT full-text search (ls) Solr

## What is the problem we are trying to solve

These files customize Solr for HT full-text search for Solr 6. Our very large indexes require significant changes to Solr defaults in order to work.  We also have custom indexing to deal with multiple languages, and very large documents.

## [Legacy] Overview Solr 6 

A solr configuration for LSS consists of five symlinks in the same directory
that point to the correct files for that core:

Three of these symlinks will point to the same file regardless of what
core you're configuring:

* `1000common.txt`.  See [background information](https://www.hathitrust.org/blogs/large-scale-search/slow-queries-and-common-words-part-2)
and [how to update the list of words](https://tools.lib.umich.edu/confluence/display/HAT/Tuning+CommonGrams+and+the+cache-warming+queries).
* `schema.xml`, the generic schema file
* `solrconfig.xml`, the generic solr configuration for handlers and config

The other two files are specific to whether it's an x/y core (`similarity.xml`)
and what the core number is `mergePolicy.xml` These are referenced in `schema.xml`
and `solrconfig.xml` via a standard XML `<!ENTITY <name> SYSTEM "./<relative_file_path>">`.
This allows us to have a single base file that can be modified just by
putting a symlink to the right file in the conf directory.


* `similarity.xml` contains directives to use either the tfidf or BM25 similarity
scores and are stored in the corresponding directories. We've
been linking the tfidf file into `core-#x` and the BM25 into `core-#y` for each
of the cores.
* `mergePolicy.xml` configures merge variables and ramBuffer size for each 
  individual core (as [specified in Confluence](https://tools.lib.umich.edu/confluence/display/HAT/Tuning+re-indexing)),
  with a goal of making them different enough that it's 
  less likely that many cores will be involved in big merges at the same time.

  Note that production solrs should symlink in `serve/mergePolicy.xml`, while the 
  indexing servers should use the core-specific version in the 
  `indexing_core_specific` directory.

Launch Solr server
`docker-compose -f lss-dev/docker-compose.yml up`

Stop Solr server
`docker-compose -f lss-dev/docker-compose.yml down` 

`docker exec -it solr-lss-dev-8 /bin/bash`


## Overview Solr 8.11.2 in standalone mode: Upgrading our index from Solr6 to Solr8.11.2 (the last version)

A Solr configuration for full-text search consists of creating a directory (solrdata) that contains all the 
files and directories Solr needs to start up the server in standalone mode and with one core (core-x).

In this first iteration, minimal changes were made on JAR files, Solr schemas and config files. The main goal was to 
re-use the previous set up with the Solr 8.

See below the follow steps to upgrade the Solr version.
1) Create a DockerFile to generate the image **Solr:8.11.2** is based image used.

- **(DockerFile) To Solr recognize the cores, a directory with the core name, should be created inside** 
the /var/solr/data folder. Inside each core directory, should be added:
  - solrconfig.xml (configuration file with the most parameters affecting Solr itself) 
  The solrconfig.xml file is located in the conf/ directory for each collection or core 
  - data directory 
  - core.properties -- Solr cores are configured by placing a file named core.properties in a sub-directory 
  under solr.home. Each core has to be the core.properties field 
  - conf directory 
  - lib directory (All the used JARS must add into lib directory)
- **(DockerFile) Inside /var/sorl/data folder should be added the file solr.xml**

2) Copy some of the Java JARS that was already generated in Catalog
   - icu4j-62.1.jar 
   - lucene-analyzers-icu-8.2.0.jar 
   - lucene-umich-solr-filters-3.0-solr-8.8.2.jar 

3) Upgrading the JAR: HTPostingsFormatWrapper (Check [here](https://github.com/hathitrust/lss_java_code/tree/master) to see all the steps to generate this JAR)

4) Updating schema.xml

* _root_ field is type=int in solr6 and type=string in Solr8. In Solr 8 _root_ field must be defined using the exact same fieldType as the uniqueKey field (id) uses: string

5) Create a docker-compose file to start up Solr server and for indexind data.

The JSON file core-data.json (/solr_json_documents) contains 1.978 generated using the python workflow. These documents are a sample of 
the documents indexed in [catalog image](https://github.com/hathitrust/hathitrust_catalog_indexer).


## How to start up the Solr server

**Create the Image using the Dockerfile**
`docker build -t solr-text-search-8 .`

**Use the docker-compose file for starting up the Solr server and for indexing data**
`docker-compose -f docker-compose.yml up`


**After indexing data, save the image and push the image to the server** [To TEST]
  * `docker container commit d00962259886 solr-text-search-8:latest`
  * `docker image tag solr-text-search-8:latest ghcr.io/hathitrust/full-text-search-solr:example-8.11`
  * `docker image push ghcr.io/hathitrust/full-text-search-solr:example-8.11`


## Overview Solr 8.11.2 in cloud mode: Upgrading our index from Solr6 to Solr8.11.2 (the last version)

A solrCloud configuration for LSS consists on a Solr cluster with a single node and a single Zookeeper ensamble to the Solr server.

A ZooKeeper Command Line Interface (CLI) script is used to interact directly with Solr configuration files stored in ZooKeeper.

The **upconfig** command is used to upload the core configuration to ZooKeeper, this way we ensure that all collections
using that configuration (throughout the Cloud, on all the servers) have that specific config. 
So you only need to upload it once, on one server.



## How to start up the Solr cloud server, create core-x collection and index documents


* `docker-compose -f docker-compose-cloud-mode.yml up`

* `cd solrcloud_setup`

* `./collection_manager.sh`


# Command to create core-x collection. Recommendation: Pass the instanceDir and the dataDir to the curl command
`curl -u solr:SolrRocks "http://localhost:8983/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"`

# Command to index documents into core-x collection
`curl -u solr:SolrRocks 'http://localhost:8983/solr/core-x/update?commit=true' --data-binary @core-data.json -H 'Content-type:application/json'`

# Others curl commands to access

* Delete a configset
`curl -u solr:SolrRocks -X DELETE "http://localhost:8983/api/cluster/configs/core-x"`

* Create a configset through a .zip file (You should create the zip file using this command: e.g. `zip -r core-x.zip core-x`)
`curl -u solr:SolrRocks -X PUT --header "Content-Type:application/octet-stream" --data-binary @core-x.zip "http://localhost:8983/api/cluster/configs/core-x"`


## Usefull comands

**Delete documents by curl command, you should add commit=true**

`curl -X POST -H 'Content-Type: application/json' \
    'http://<host>:<port>/solr/<core>/update?commit=true' \
    -d '{ "delete": {"query":"*:*"} }'`

curl `http://localhost:8983/solr/admin/collections?action=CREATE&name=core-x&numShards=2&replicationFactor=1&wt=xml`

**Export JSON file with index documents**
`curl "http://localhost:8983/solr/core-x/select?q=*%3A*&wt=json&indent=true&start=0&rows=2000000000&fl=*" > full-output-of-my-solr-index.json`

Below one can be used through browser:

`http://host:port/solr/collection_name/update?commit=true&stream.body=<delete><query>*:*</query></delete>`

## Deployment and Use

### Re-Indexing

Notes about customizing solrconfig.xml go here
### Testing
### Deployment to Production
### Production Indexing
### Production Serving


## Migrating to later versions of Solr/Lucene
This may need a separate document on confluence.  Think about it...

## Background details

## Considerations for future modification

### Move to AWS


### Testing


## Links to more background
