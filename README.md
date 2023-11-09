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


# Overview Solr 8.11.2 in standalone mode


### Upgrading our index from Solr6 to Solr8.11.2 (the last version)

A Solr configuration for full-text search consists of creating a directory (solrdata) that contains all the 
files and directories Solr needs to start up the server in standalone mode and with one core (core-x).

In this first iteration, minimal changes were made on JAR files, Solr schemas and config files. The main goal was to 
re-use the previous set-up with the Solr 8.

    See below the follow steps to upgrade the Solr version.
1) **Create a DockerFile to generate the image **Solr:8.11.2** is based image used**.

- (DockerFile) To Solr recognize the cores, a directory with the core name, should be created inside** 
the /var/solr/data folder. Inside each core directory, should be added:
  - solrconfig.xml (configuration file with the most parameters affecting Solr itself) 
  The solrconfig.xml file is located in the conf/ directory for each collection or core 
  - data directory 
  - core.properties -- Solr cores are configured by placing a file named core.properties in a sub-directory 
  under solr.home. Each core has to be the core.properties field 
  - conf directory 
  - lib directory (All the used JARS must add into lib directory)
- **(DockerFile) Inside /var/sorl/data folder should be added the file solr.xml**

2) **Copy some of the Java JARS that was already generated in Catalog**
   - icu4j-62.1.jar 
   - lucene-analyzers-icu-8.2.0.jar 
   - lucene-umich-solr-filters-3.0-solr-8.8.2.jar 

3) **Upgrading the JAR: HTPostingsFormatWrapper** (Check [here](https://github.com/hathitrust/lss_java_code/tree/master) to see all the steps to generate this JAR)

4) **Updating schema.xml**

* _root_ field is type=int in solr6 and type=string in Solr8. In Solr 8 _root_ field must be defined using the exact same fieldType as the uniqueKey field (id) uses: string

5) **Create a docker-compose file to start up Solr server and for indexing data**.

The JSON file core-data.json (/solr_json_documents) contains 1.978 generated using the python workflow. These documents are a sample of 
the documents indexed in [catalog image](https://github.com/hathitrust/hathitrust_catalog_indexer).


### How to start up the Solr server in a standalone mode

* Create the Image using the Dockerfile 
  * `docker build -t solr-text-search-8-standalone solr_standalone_mode`
* Use the docker-compose file for starting up the Solr server and for indexing data
  * `docker-compose -f docker-compose_solr8_standalone_mode.yml up`

#### How to integrate in babel-local-dev

Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications:

````
  solr-lss-dev:
    container_name: solr-lss-dev
    healthcheck:
        test: [ "CMD", "/usr/bin/curl", "-s", "-f", "http://solr-lss-dev:8983/solr/core-x/admin/ping" ]
        interval: 5s
        timeout: 10s
        start_period: 30s
        retries: 5
    build: ./lss_solr_configs/solr_standalone_mode
    ports:
      - "8983:8983"
    volumes:
      - ${PWD}/lss_solr_configs/solr_standalone_mode/solrdata:/var/solr/data
  data_loader:
    build: ./lss_solr_configs/solr_standalone_mode
    entrypoint: ["/bin/sh", "-c", "curl 'http://solr-lss-dev:8983/solr/core-x/update?commit=true' --data-binary @solrdata/core-data.json -H 'Content-type:application/json'"]
    volumes:
      - ${PWD}/lss_solr_configs/solr_standalone_mode/solrdata:/var/solr/data
    depends_on:
      solr-lss-dev:
        condition: service_healthy
````

# Overview Solr 8.11.2 in cloud mode: 

### Upgrading our index from Solr6 to Solr8.11.2 (the last version)

A solrCloud configuration for full-text search consists on a Solr cluster with a single node and a single Zookeeper. Two different
architecture has tested to set up solr in cloud mode.

* Option 1: Solr 8.11.2 Solr’s embedded ZooKeeper instance
* Option 2: Solr 8.11.2 Set up Solr and an external Zookeeper ensemble


### Solr 8.11.2 Solr’s embedded ZooKeeper instance

* Using Solr’s embedded ZooKeeper instance is fine for getting started, development stages
* This set-up is not use in production because, the Solr instance also host Zookeeper, then if Solr shuts down, Zookeeper is also shut down. 
Any shards or Solr instances that rely on it will not be able to communicate with it or each other. 
* It is the best alternative if you want to integrate SolrCloud 8 in babel-local-dev repository

    #### How to start up the Solr server

    * Build an image: 
      * `docker build -t full-text-search-embedded_zoo solrCloud_embedded_zooKeeper`
    * Execute the container: 
      * `docker compose -f docker-compose_embedded_zooKeeper.yml up`
    
    * Build the image in the repository
      * `docker build -t ghcr.io/hathitrust/full-text-cloud-embedded_zookeeper:example_8.11 solrCloud_embedded_zooKeeper`
    
    * Push the image to use it in different projects
      * `docker image push ghcr.io/hathitrust/full-text-cloud-embedded_zookeeper:example_8.11`
    
    #### How to integrate in babel-local-dev

    Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications

```solr-lss-dev:
    image: ghcr.io/hathitrust/full-text-cloud-embedded_zookeeper:example_8.11 
    #build: ./lss_solr_configs/solrcloud_setup #solrcloud_setup/.
    container_name: solr-lss-dev
    ports:
     - "8983:8983"
    volumes:
      - solr_data:/var/solr/data
    command: solr-foreground -c
    healthcheck:
      test: ["CMD-SHELL", "solr healthcheck -c core-x"]
      interval: 5s
      timeout: 10s
      start_period: 30s
      retries: 5
  data_loader:
      build: ./lss_solr_configs/solrCloud_embedded_zooKeeper
      entrypoint: [ "/bin/sh", "-c", "curl 'http://solr-lss-dev:8983/solr/core-x/update?commit=true' --data-binary @/var/solr/data/core-data.json -H 'Content-type:application/json'" ]
      volumes:
        - solr_data:/var/solr/data
      depends_on:
        solr-lss-dev:
          condition: service_healthy
```

You might add the volume solr_data to the list of volume.
 
### Solr 8.11.2 Set up Solr and an external Zookeeper ensemble

* This is the recommended architecture for production environment
* In our soluction authentication is applied
* The integration in babel-local-dev repository is more verbose
* No docker image is generate becuase several service are running inside the docker

    #### How to start up the Solr server

The docker starts up a Solr server without collections, then the script collection_manager.sh should be executed to create 
the collection and index documents in the index.

* Execute the container: 
  * `docker compose -f docker-compose_external_zooKeeper.yml up`

* Run an script for creating collection and indexing data
  * `cd solrCloud_external_zooKeeper`
  * `docker exec solr1 /var/solr/data/collection_manager.sh`

    #### How to integrate in babel-local-dev

Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications

```solr-lss-dev:
    build: ./lss_solr_configs/solrCloud_external_zooKeeper
    container_name: solr-lss-dev
    ports:
     - "8983:8983"
    environment:
      - ZK_HOST=zoo1:2181
      - SOLR_OPTS=-XX:-UseLargePages 
    depends_on:
      - zoo1
    volumes:
      - solr1_data:/var/solr/data
    command:
      - solr-foreground
  zoo1:
    image: zookeeper:3.6
    container_name: zoo1
    restart: always
    hostname: zoo1
    ports:
      - 2181:2181
    environment:
      ZOO_MY_ID: 1 
      ZOO_SERVERS: server.1=zoo1:2888:3888;2181
      ZOO_4LW_COMMANDS_WHITELIST: mntr, conf, ruok
      ZOO_CFG_EXTRA: "metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider metricsProvider.httpPort=7000 metricsProvider.exportJvmInfo=true"
      ZOO_LOG_DIR: "/logs"
    volumes:
      - zookeeper1_log:/logs
      - zookeeper1_data:/data
      - zookeeper1_datalog:/datalog
      - zookeeper1_wd:/apache-zookeeper-3.6.0-bin
```

You might add the volume following list of volume to the docker-compose file.

```solr1_data:

  zookeeper1_data:
  zookeeper1_datalog:
  zookeeper1_log:
  zookeeper1_wd:

```

* To start up the application, 
  * docker-compose build 
  * docker-compose up 

* and to create the collection and index documents in full-text search server use the command below
  * `docker exec solr-lss-dev /var/solr/data/collection_manager.sh`


## Useful commands

* Command to create core-x collection. Recommendation: Pass the instanceDir and the dataDir to the curl command
  * `curl -u solr:SolrRocks "http://localhost:8983/solr/admin/collections?action=CREATE&name=core-x&instanceDir=/var/solr/data/core-x&numShards=1&collection.configName=core-x&dataDir=/var/solr/data/core-x"`

* Command to index documents into core-x collection, remove authentication if you do not need it
  * `curl -u solr:SolrRocks 'http://localhost:8983/solr/core-x/update?commit=true' --data-binary @core-data.json -H 'Content-type:application/json'`

* Delete a configset
  * `curl -u solr:SolrRocks -X DELETE "http://localhost:8983/api/cluster/configs/core-x"`

* Create a configset through a .zip file (You should create the zip file using this command: e.g. `zip -r core-x.zip core-x`)
  * `curl -u solr:SolrRocks -X PUT --header "Content-Type:application/octet-stream" --data-binary @core-x.zip "http://localhost:8983/api/cluster/configs/core-x"`

* Delete documents, you should add commit=true
  * `curl -X POST -H 'Content-Type: application/json' \
      'http://<host>:<port>/solr/<core>/update?commit=true' \
      -d '{ "delete": {"query":"*:*"} }'`

* Export JSON file with index documents
  * `curl "http://localhost:8983/solr/core-x/select?q=*%3A*&wt=json&indent=true&start=0&rows=2000000000&fl=*" > full-output-of-my-solr-index.json`

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

* [docker solr examples](https://github.com/docker-solr/docker-solr-examples/tree/master/custom-configset): https://github.com/docker-solr/docker-solr-examples/tree/master/custom-configset
* [SolrCloud & Catalog indexing](https://github.com/mlibrary/catalog-browse-indexing/blob/main/docker-compose.yml)
* [SolrCloud + ZooKeeper external server & data persistence](https://github.com/samuelrac/solr-cloud)
* [Our documentation with more information](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/edit-v2/2661482577)
* [An example of SolrCloud in Catalog](https://github.com/hathitrust/hathitrust_catalog_indexer/blob/main/README.md)
* 