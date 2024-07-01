# lss_solr_configs
Configuration files for HT full-text search (ls) Solr

## What is the problem we are trying to solve

These files customize Solr for HT full-text search for Solr 6 and 8 and in standalone and cloud mode. 
Our very large indexes require significant changes to Solr defaults in order to work.  
We also have custom indexing to deal with multiple languages, and very large documents.

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

### How to start up the Solr 6 server in a standalone mode

* Launch Solr server
  * `docker-compose -f docker-compose_solr6_standalone.yml up`

* Stop Solr server
  * `docker-compose -f docker-compose_solr6_standalone down` 

* Go inside the Solr container
  * `docker exec -it solr-lss-dev-8 /bin/bash`

If you are using Apple Silicon M1 chip, you will get this error -no matching manifest for Linux/arm64/v8 in the 
manifest list entries-. To fix it, just add this platform in the docker-compose.yml file as shown below:

`platform: linux/amd64`

#### How to integrate it in babel-local-dev

Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications:

```solr-lss-dev:
    image: solr:6.6.6-alpine
    ports:
      - "8983:8983"
    user: ${CURRENT_USER}
    volumes:
      - ${BABEL_HOME}/lss_solr_configs/solr6_standalone/lss-dev/core-x:/opt/solr/server/solr/core-x
      - ${BABEL_HOME}/lss_solr_configs/solr6_standalone/lss-dev/core-y:/opt/solr/server/solr/core-y
      - ${BABEL_HOME}/lss_solr_configs/solr6_standalone:/opt/lss_solr_configs
      - ${BABEL_HOME}/lss_solr_configs/solr6_standalone/lib:/opt/solr/server/solr/lib
      - ${BABEL_HOME}/logs/solr:/opt/solr/server/logs
 ```

# Overview Solr 8.11.2 in standalone mode

* Solr8.11.2 is the latest version of the 8.x series
* 

### Upgrading our index from Solr6 to Solr8.11.2 (the last version)

A Solr configuration for full-text search consists of creating a directory (solrdata) that contains all the 
files and directories Solr needs to start up the server in standalone mode and with one core (core-x).

To set up Solr 8, the same logic and resources used with Solr 6 was reused, then, minimal changes were made on JAR files, 
Solr schemas and config files.

See below the followed steps to upgrade the server from Solr 6 to Solr 8.

1) **Create a DockerFile to generate our own image. **Solr:8.11.2** was the image used**.

- (DockerFile) To Solr recognize the cores, a directory with the core name, should be created inside** 
the /var/solr/data folder. Inside each core directory, should be added:
  - solrconfig.xml (configuration file with the most parameters affecting Solr itself) 
  The solrconfig.xml file is located in the conf/ directory for each collection or core 
  - data directory 
  - core.properties -- Solr cores are configured by placing a file named core.properties in a subdirectory 
  under solr.home. Each core has to be the core.properties field 
  - conf directory 
  - lib directory (All the used JARS must add into lib directory)
- **(DockerFile) In /var/sorl/data directory should be added the file solr.xml**

2) **Copy some of the Java JARS that was already generated in Catalog**
   - icu4j-62.1.jar 
   - lucene-analyzers-icu-8.2.0.jar 
   - lucene-umich-solr-filters-3.0-solr-8.8.2.jar 

3) **Upgrading the JAR: HTPostingsFormatWrapper** (Check [here](https://github.com/hathitrust/lss_java_code/tree/master) to see all the steps to re-generate this JAR)

4) **Updating schema.xml**

* _root_ field is type=int in Solr6 and type=string in Solr8. In Solr 8 _root_ field must be defined using the exact same fieldType as the uniqueKey field (id) uses: string

5) **Create a docker-compose file to start up Solr server and for indexing data**.

### How to start up the Solr server in a standalone mode

* Use the docker-compose file for starting up the Solr server and for indexing data
  * `docker compose -f docker-compose_solr8_standalone_mode.yml up`

#### How to integrate it in babel-local-dev

Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications:

````
  solr-lss-dev:
    container_name: solr-lss-dev
    image: solr-lss-dev
    build:
        context: ./lss_solr_configs
        dockerfile: ./solr8.11.2_files/Dockerfile
        target: standalone
    healthcheck:
        test: [ "CMD", "/usr/bin/curl", "-s", "-f", "http://solr-lss-dev:8983/solr/core-x/admin/ping" ]
        interval: 5s
        timeout: 10s
        start_period: 30s
        retries: 5
    ports:
      - "8983:8983"
    volumes:
      - solr_data:/var/solr/data
volumes:
  solr_data:
````

# Overview Solr 8.11.2 in cloud mode: 

* In the first iteration, the SolrCloud is a single replica and a single shard
* The server was set up combining Solr, ZooKeeper and Docker
* For development, the Solr instance also have an embedded ZooKeeper server
* For production, we should use an external ZooKeeper server

To start up the Solr server in cloud mode, we mount the script init_files/solr_init.sh in the container 
to allow setting up the authentication using a predefined security.json file.

The script specifies the ZK_HOST environment variable to point to the ZooKeeper server. It also copies the 
security.json file to ZooKeeper using the solr zk cp command. In the docker-compose file, each Solr container should
run a command to start up the Solr in foreground mode. 

In the container, we should define health checks to verify the Zookeeper and Solr are working well. These health checks
will help us to define the dependencies between the services in the docker-compose file.

If we do not use the health checks, we probably will have to use the scripts wait-for-solr.sh and wait-for-zookeeper.sh 
to make sure the authentication is set up correctly.

### Upgrading our index from Solr6 to Solr8.11.2 (the last version)

A solrCloud configuration for full-text search consists on a Solr cluster with a single node and a single Zookeeper. Two different
architecture has tested to set up solr in cloud mode.

* Option 1: Version 8.11.2 Solr’s embedded ZooKeeper instance
* Option 2: Version 8.11.2 Solr and an external Zookeeper ensemble

### Solr 8.11.2 and embedded ZooKeeper instance

* Using Solr’s embedded ZooKeeper instance is fine for getting started, development stages
* This set-up is not use in production because, the Solr instance also host Zookeeper, then if Solr shuts down, 
Zookeeper is also shut down. 
Any shards or Solr instances that rely on it will not be able to communicate with it or each other. 
* It is the best alternative if you want to integrate SolrCloud 8 in babel-local-dev repository
* A [ZooKeeper Command Line Interface](https://solr.apache.org/guide/solr/latest/deployment-guide/zookeeper-utilities.html) 
was used to configure our own collections

    #### How to start up the Solr server

    * Execute the container: 
      * `docker compose -f docker-compose_embedded_zooKeeper.yml up`
    
    * The docker-compose file, will create images for Solr and to index data, you can push the images to the registry repository
      * Solr: 
        * Associate the local image with the image to register 
          * `docker image tag full-text-search-embedded_zoo:latest ghcr.io/hathitrust/full-text-search-embedded_zoo:example-8.11`
        * Push the image
          * `docker image push ghcr.io/hathitrust/full-text-search-embedded_zoo:example-8.11`
      * Data loader:
        * Associate the local image with the image to register 
          * `docker image tag lss_solr_configs-data_loader:latest ghcr.io/hathitrust/lss_solr_configs-data_loader:example-8.11`
        * Push the image
          * `docker image push ghcr.io/hathitrust/lss_solr_configs-data_loader:example-8.11`


    #### How to integrate it in babel-local-dev

    Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications

```solr-lss-dev:
   build:
      context: ./lss_solr_configs
      dockerfile: ./solr8.11.2_files/Dockerfile
      target: embedded_zookeeper
    container_name: solr-lss-dev
    ports:
      - "8983:8983"
    volumes:
      - solr_data:/var/solr/data
    command: solr-foreground -c
    healthcheck:
      test: [ "CMD-SHELL", "solr healthcheck -c core-x" ]
      interval: 5s
      timeout: 10s
      start_period: 30s
      retries: 5
```
  #### How to integrate with python full-text search indexer workflow using the images

```solr-lss-dev:
    image: ghcr.io/hathitrust/full-text-search-embedded_zoo:example-8.11
    container_name: solr-lss-dev
    ports:
      - "8983:8983"
    volumes:
      - solr_data:/var/solr/data
    command: solr-foreground -c
    healthcheck:
      test: [ "CMD-SHELL", "solr healthcheck -c core-x" ]
      interval: 5s
      timeout: 10s
      start_period: 30s
      retries: 5
```

You might add the volume solr_data to the list of volume.
 
## Solr 8.11.2 and an external Zookeeper

* This is the recommended architecture for production environment
* In our solution, authentication is applied
* The integration in babel-local-dev repository is more verbose
* No docker image is generated because some services are running inside the docker
* In the docker-compose file, the address (a string) where ZooKeeper is running is defined, this way Solr is able 
to connect to ZooKeeper server 
* Use [Solr API](https://solr.apache.org/guide/8_11/collections-api.html) for creating and set up the collection

To a better understanding of Solr and Zookeeper set up in a docker, see this [page](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/3190292502/Solr+cloud+and+external+Zookeeper+parameters).

### How to create the image for Solr and external Zookeeper    

```
cd lss_solr_configs
export IMAGE_REPO=ghcr.io/hathitrust/full-text-search-external_zoo
docker build . --file solr8.11.2_files/Dockerfile --target external_zookeeper --tag $IMAGE_REPO:ext_zoo_8.11.2
docker image tag xt_zoo_8.11.2:latest ghcr.io/hathitrust/full-text-search-external_zoo:shards-8.11
docker image push ghcr.io/hathitrust/full-text-search-external_zoo:shards-8.11
```

If you are doing changes in the Dockerfile or in the solr_init.sh script it is better to create the image
each time you run the docker-compose file instead of using the image in the repository.

Update the solr service adding the following lines:

```build:
    context: .
    dockerfile: ./solr8.11.2_files/Dockerfile
    target: external_zookeeper
```

You should use the created image in the docker-container to start up `full-text-search-external_zoo` service

### How to start up the Solr server and use it to create the collection and configset

This application uses the script solrCloud_external_zooKeeper/init_files/solr_init.sh to start up the Solr cluster
with Basic authentication and uploading the configset used in the collection with fulltext documents.

#### Command to start up the Solr cluster in cloud mode 
  `docker compose -f docker-compose_external_zooKeeper.yml up`

You will see the following services running in the docker:
* full-text-search-external_zoo
* zoo1

You could use this option if you want to use Solr with any other application.

#### Command to start up the Solr cluster in cloud mode and create the collection and configset

The docker-compose (docker-compose_external_zooKeeper.yml) file contains additional services you can use with 
Solr cluster if you start the docker using `--profile` option.

* Use the command below to create the collection using core-x configset. 

```
export SOLR_PASSWORD='solr-admin-password'
docker compose -f docker-compose_external_zooKeeper.yml --profile collection_creator up
```

`collection_creator` is a service that will create the collection `core-x` using the already 
created configset `core-x`. The configset core-x is uploaded when Solr server starts up.
To create collections, solr-admin-password is required; then it should be passed as an environment variable.

* The following service will be created in the docker-compose file
  * full-text-search-external_zoo
  * zoo1
  * collection_creator

* Use the command below to start up the Solr cluster in cloud mode and manage Solr collections and configset using
the python module solr_manager. Read solr_manager/README.md to see how to use this module.

```
docker compose -f docker-compose_external_zooKeeper.yml --profile solr_collection_manager up
```

#### How to integrate it in babel-local-dev

Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications

```solr-lss-dev:
     image: ghcr.io/hathitrust/full-text-search-external_zoo:shards-8.11
     container_name: full-text-search-external_zoo
     ports:
      - "8983:8983"
     environment:
      - ZK_HOST=zoo1:2181
      - SOLR_OPTS=-XX:-UseLargePages
    networks:
      - solr
    depends_on:
      zoo1:
        condition: service_healthy
    volumes:
      - solr1_data:/var/solr/data
    command: # Solr command to start the container to make sure the security.json is created
      - solr-foreground -c
    healthcheck:
      test: [ "CMD", "/usr/bin/curl", "-s", "-f", "http://full-text-search-external_zoo:8983/solr/#/admin/ping" ]
      interval: 5s
      timeout: 10s
      start_period: 30s
      retries: 5
  zoo1:
    image: zookeeper:3.8.0
    container_name: zoo1
    restart: always
    hostname: zoo1
    ports:
      - 2181:2181
      - 7001:7000
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=zoo1:2888:3888;2181
      ZOO_4LW_COMMANDS_WHITELIST: mntr, conf, ruok
      ZOO_CFG_EXTRA: "metricsProvider.className=org.apache.zookeeper.metrics.prometheus.PrometheusMetricsProvider metricsProvider.httpPort=7000 metricsProvider.exportJvmInfo=true"
      ZOO_LOG_DIR: "/logs"
    networks:
      - solr
    volumes:
      - zookeeper1_log:/logs # The log directory is used to store the Zookeeper logs
      - zookeeper1_data:/data # The data directory is used to store the Zookeeper data
      - zookeeper1_datalog:/datalog # The datalog directory is used to store the Zookeeper transaction logs
    healthcheck:
      test: [ "CMD", "/usr/bin/curl", "-s", "-f", "http://solr1:8983/solr/#/admin/ping" ]
      interval: 30s
      timeout: 10s
      retries: 5
  collection_creator:
    container_name: collection_creator
    build:
      context: .
      dockerfile: ./solr8.11.2_files/Dockerfile
      target: external_zookeeper
    entrypoint: [ "/bin/sh", "-c" ,"/var/solr/data/collection_manager.sh http://full-text-search-external_zoo:8983"]
    volumes:
      - solr1_data:/var/solr/data
    depends_on:
      full-text-search-external_zoo:
        condition: service_healthy
    networks:
      - solr
    profiles: [create_collections]
    environment:
      - SOLR_PASSWORD=$SOLR_PASSWORD
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
  
## How to index data using a sample of documents

Follow the steps below for indexing a sample of documents in Solr server. 

The sample of data is in `macc-ht-ingest-000.umdl.umich.edu:/htprep/fulltext_indexing_sample/data_sample.zip`

* Download a zip file with a sample of documents to your local environment
`scp macc-ht-ingest-000.umdl.umich.edu:/htprep/fulltext_indexing_sample/data_sample.zip ~/datasets` 

* In your working directory,
  * After starting up the Solr server inside the docker,
  * run the script `./indexing_data.sh`. 
  
  The script will extract all the XML files inside the Zip file to a destine folder. Then, it will index the documents in Solr server. 
The script input parameters are: solr_url, the path to the target folder to extract the files and the path to the zip file.
  * e.g. `./indexing_data.sh http://localhost:8983 ~/mydata data_sample.zip`

At the end of this process, your Solr server should have a sample of 150 documents.

**Note**: If in the future we should automatize this process, a service to index documents could be included in the docker-compose. 
You will have to add the data sample to the docker image or download it from a repository. See the example below as a reference

```data_loader:
    build:
      context: ./lss_solr_configs
      dockerfile: ./solr8.11.2_files/Dockerfile
      target: external_zookeeper
    entrypoint: [ "/bin/sh", "-c" ,"indexing_data.sh http://solr-lss-dev:8983" ]
    volumes:
      - solr1_data:/var/solr/data
    depends_on:
      collection_creator:
        condition: service_completed_successfully
    networks:
      - solr
```

## Create a JSON file for indexing data

The JSON file core-data.json (/solr_json_documents) contains 1.978 generated using the python workflow. These documents are a sample of 
the documents indexed in [catalog image](https://github.com/hathitrust/hathitrust_catalog_indexer).


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
 
* Below one can be used through browser to delete documents from Solr index:
  * `http://host:port/solr/collection_name/update?commit=true&stream.body=<delete><query>*:*</query></delete>`

### Pending & Next steps

* [Otimization] To simplify the dokerization logic some directories have been duplicated in the different directories to
set up Solr cloud. We could check how the common directories could be added in the root of the repository and re-use
them in the docker files.

## Deployment and Use

Go to section `How to integrate it in babel-local-dev` to see how to integrate each Solr server into another application.

### Re-Indexing

* To solve the issue below, the solrconfig.xml file was updated to enable the updateLog option.

```ERROR org.apache.solr.cloud.SyncStrategy – No UpdateLog found - cannot sync```

* In the Solr cloud logs with embedded ZooKeeper you could see the issue below. That is more of a warning than error, and 
it appears because we are running only one ZK in standalone mode. More details of this
message [here](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/edit-v2/2661482577).

```Invalid configuration, only one server specified (ignoring)```

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