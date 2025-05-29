<br/>
  <p align="center">
    lss_solr_configs
    <br/>
    <br/>
    <a href="https://github.com/hathitrust/lss_solr_configs/issues">Report Bug</a>
    -
    <a href="https://github.com/hathitrust/lss_solr_configs/issues">Request Feature</a>
  </p>

## Table Of Contents

* [About the Project](#about-the-project)
* [Built With](#built-with)
* [Phases](#phases)
* [Project Set Up](#project-set-up)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
  * [Creating A Pull Request](#creating-a-pull-request)
* [Content Structure](#content-structure)
  * [Project Structure](#project-structure)
  * [Site Maps](#site-maps)
* [Design](#design)
* [Functionality](#functionality)
* [Usage](#usage)
* [Tests](#tests)
* [Hosting](#hosting)
* [Resources](#resources)

## About The Project

This project is a configuration for Solr 6 and 8 to be used in the HathiTrust full-text search. 

The main problem we are trying to solve is to provide HathiTrust custom architecture to Solr server to deal with:
* Huge indexes that require significant changes to Solr default to work;
* Custom indexing to deal with multiple languages and huge documents.

The initial version of the HT Solr cluster runs in Solr 6 in standalone mode. The current proposal of this repository
is to upgrade the Solr server to Solr 8 in cloud mode. However, the Solr 6 server documentation will be here for a
while as legacy and to use it as a reference.

## Built With

* [Solr](https://lucene.apache.org/solr/)
* [Docker](https://www.docker.com/)
* [Kubernetes](https://kubernetes.io/)
* [Python](https://www.python.org/)
* [Java](https://www.java.com/)
* [Bash](https://www.gnu.org/software/bash/)
* [XML](https://www.w3.org/XML/)

## Phases

The project is divided into several phases. Each phase has a specific goal to achieve.

* **Phase 1**: Upgrade Solr server from Solr 6 to Solr 8 in cloud mode
    * Understand the Solr 6 architecture to migrate to Solr 8
    * Create a docker image for Solr 8 in cloud mode
      * Create a Docker image for Solr 8 and external Zookeeper
      * Create a Docker image for Solr 8 and embedded Zookeeper
* **Phase 2**: Index data in Solr 8 and integrate it in [babel-local-dev](https://github.com/hathitrust/babel-local-dev) 
and [ht_indexer](https://github.com/hathitrust/ht_indexer)
  * Create a script to automate the process of indexing data in Solr 8
* **Phase 3**: Set up the Solr cluster in Kubernetes with data persistence and security
  * Create a Kubernetes deployment for Solr 8 and external Zookeeper
  * Deploy the Solr cluster in Kubernetes
  * Create a Python module to manage Solr collections and configsets
  * Clean up the code and documentation
* **Phase 4**: Upgrade Solr image from Solr 8.11.2 to Solr 8.11.4
  * As it is a minor upgrade, it should not break the existing configurations and data, so just the Dockerfile will be updated.
  
## Project Set Up

### Prerequisites

* Docker
* Python
* Java

### Installation

1. Clone the repo
   ``` git clone git@github.com:hathitrust/lss_solr_configs.git ```

2. Start the Solr server in standalone mode
   ``` docker compose -f docker-compose_solr6_standalone.yml up ```

3. Start the Solr server in cloud mode
   ``` docker compose -f docker-compose.yml up ```

## Content Structure

### Project Structure

```
lss_solr_configs/
├── solr_manager/
│   ├── Dockerfile
│   ├── .env
│   ├── solr_init.sh
│   ├── security.json
│   ├── collection_manager.sh
│   └── README.md
├── solr_cloud/
│   ├── Dockerfile
│   ├── solrconfig.xml
│   ├── schema.xml
│   ├── core.properties
│   ├── lib/
│   └── data/
├── solr6_standalone/
├── docker-compose_test.yml
├── docker-compose_solr6_standalone.yml
├── README.md
└── indexing_data.sh
```

## Design

* **solr6_standalone**: Contains the Dockerfile and configuration files for Solr 6 in standalone mode.
* **solr_cloud**: Contains the Dockerfile and configuration files for Solr in cloud mode.
  * Dockerfile: Dockerfile for building the Solr cloud image.
    * Create the image with the target:**external_zookeeper_docker** to run Solr in Docker. This application uses 
    the script init_files/solr_init.sh to copy a custom security.json file to initialize Solr and external 
      Zookeeper using the Basic authentication.
      * Create the image with the target: **common** to run Solr in Kubernetes. Solr will start automatically without
      the need to run the script solr_init.sh.

The image will copy files that are relevant to set up the cluster

* **conf/**: Directory for Solr configuration files. 
  * solrconfig.xml: Solr configuration file. 
  * schema.xml: Solr schema file. 
* **lib/**: Directory for JAR files.

The Solr server will start up without any collections. Collections and configsets are created using `solr_manager` 
application.

* **solr_manager**: Contains the Dockerfile and scripts for managing Solr collections and configurations using Python.
  * This application will have access to any Solr server running in Docker or Kubernetes.
  * Inside the `solr_manager`, you will see the Dockerfile for building the image to run the Python application and its 
  documentation.
  * To create collections and to upload configsets, Solr requires Admin credentials, and then you will need it 
  to provide the Solr admin password as an environment variable. 
  Find [here](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/3109158919/Customize+our+Solr+cluster+in+Kubernetes) 
  admin credentials. 
* **indexing_data.sh**: Use this script for indexing data into Solr when the Solr cluster is running and the collections are created. 
  It will extract the XML files from a zip file and index them into Solr. 
  The script receives the Solr URL, Solr password, path to the zip file with the XML files, and the collection name as parameters.

### [Legacy] Overview Solr 6 

A Solr configuration for LSS consists of five symlinks in the same directory that point to the correct 
files for that core:

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
   core (as [specified in Confluence](https://tools.lib.umich.edu/confluence/display/HAT/Tuning+re-indexing)),
  with a goal of making them different enough that it's 
  less likely that many cores will be involved in big merges at the same time.

  Note that production solrs should symlink in `serve/mergePolicy.xml`, while the 
  indexing servers should use the core-specific version in the 
  `indexing_core_specific` directory.

### Overview Solr 8

* Solr8.11 is the latest version of the 8.x series

### Upgrading our index from Solr6 to Solr8.11

To set up Solr 8, the same logic and resources used with Solr 6 have reused; then minimal changes were made on JAR files, 
Solr schemas, and solrconfig.xml files.

See below the following steps to upgrade the server from Solr 6 to Solr 8.

1) **Create a DockerFile to generate our own image. 

- (DockerFile) The image was built using the official Solr image **Solr:8.11.2**
  and adding the necessary files to set up the Solr server. We have to ensure the lib (JAR files)
  directories are copied to the image. 
  - The lib directory contains the JAR files. 
  - The folder conf, which contains the configuration files used by Solr to index the documents, such as:
    - schema.xml: The schema file that defines the fields and types of the documents
    - solrconfig.xml: The configuration file that defines the handlers and configurations of the Solr server
    - security.json: The security file that defines the authentication to access the Solr server
- The image was built with the target **external_zookeeper_docker** 
  to run Solr in Docker. This application uses the script init_files/solr_init.sh to copy a custom security.json file to 
  initialize Solr and external Zookeeper using Basic authentication. 
  The image was built with the target **common** to run Solr in Kubernetes. 
Solr will start automatically without the need to run the script solr_init.sh.

2) **Copy some of the Java JARS that were already generated in Catalog**
   - icu4j-62.1.jar 
   - lucene-analyzers-icu-8.2.0.jar 
   - lucene-umich-solr-filters-3.0-solr-8.8.2.jar 

3) **Upgrading the JAR: HTPostingsFormatWrapper** (Check [here](https://github.com/hathitrust/lss_java_code/tree/master) to see all the steps to re-generate this JAR)

4) **Updating schema.xml**
   * _root_ field is type=int in Solr6 and type=string in Solr8. In Solr 8 _root_ field must be defined 
   using the exact same fieldType as the uniqueKey field (id) uses: string
5) **Updating solr_cloud/conf/solrconfig.xml**
   * This file has been updated along with this project. The date of each update was added in the file to track the changes.
6) **Create a docker-compose file to start up Solr server and for indexing data**.

* On docker, the SolrCloud is a single replica and a single shard.
  If you want to add more nodes of Solr and Zookeeper, you should copy solr and
zookeeper services in the docker-compose file. 
Remember to update the port of each service.

Although different architectures to set up Solr cloud have tested, the best option is to use an external 
Zookeeper server because: 

* It is the recommended architecture for production environment;
* It is more stable and secure (In our solution, authentication is applied);
* It is easier to manage the Solr cluster and Zookeeper separately;
* It is easier to scale the Solr cluster.

### Functionality

In the docker-compose.yml file, the address (a string) where ZooKeeper is running is defined; this way Solr is able 
to connect to ZooKeeper server. 
Additional environment variables have been added to ensure the Solr server starts up. 
On this [page](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/3190292502/Solr+cloud+and+external+Zookeeper+parameters), 
You can find a detail explanation of the environment variables used to set up Solr and Zookeeper in a docker. 

When the Solr cluster starts up, it is empty. 
To upload configset and create new collections, the 
[Solr API](https://solr.apache.org/guide/8_11/collections-api.html) is used for. 
In this repository, 
the Python package **solr_manager** is based on Solr collection API to manage Solr collections and configsets.

On Docker, to start up the Solr server in cloud mode, we mount the script `init_files/solr_init.sh` in the container 
to allow setting up the authentication using a predefined `security.json` file.
It also copies the security.json file to ZooKeeper using the solr `zk cp` command. 
In the docker-compose.yml file, each Solr container should
run a command to start up Solr in foreground mode. 

In the container, we should define health checks to verify that the Zookeeper and Solr are working well. 
These health checks
will help us to define the dependencies between the services in the Docker-Compose file.

If we do not use the health checks,
we probably will have to use the scripts `wait-for-solr.sh` and `wait-for-zookeeper.sh` 
to make sure the authentication is set up correctly.

On Kubernetes, no script is necessary to set up the authentication because the Solr operator
will create the secrets by default.

### Usage

#### How to start up the Solr 6 server in a standalone mode

* Launch Solr server
  * `docker compose -f docker-compose_solr6_standalone.yml up`

* Stop Solr server
  * `docker compose -f docker-compose_solr6_standalone down` 

* Go inside the Solr container
  * `docker exec -it solr-lss-dev-8 /bin/bash`

If you are using Apple Silicon M1 chip, you will get this error `-no matching manifest for Linux/arm64/v8 in the 
manifest list entries-`. 
To fix it, add this platform in the docker-compose.yml file as shown below:

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

#### How to start up the Solr 8 server in clode mode with external Zookeeper

```
docker compose -f docker-compose.yml up
```

* Start up the Solr server in cloud mode with external Zookeeper. The following services will run in the docker-compose file:
  * solr1
  * zoo1

In the folder `.github/workflows`, there is a workflow to create the image for Solr and external Zookeeper. 
This workflow creates the image for the different platforms 
(`linux/amd64`, `linux/arm64`, `linux/arm/v7`) and pushes the image to the
GitHub container registry. 
You should use this image to start up the Solr server in Kubernetes.

In Kubernetes, you should use `multiple platform images` to run the Solr server.
The recommendation is to use the [GitHub Actions workflow](https://github.com/hathitrust/lss_solr_configs/actions) 
to create the image for the different platforms. 

If you are doing changes in the Dockerfile or in the `solr_init.sh script`, it is better to create the image
each time you run the `docker-compose.yml` file instead of using the image in the repository.

Update the Solr service adding the following lines:
```
    build:
      context: .
      dockerfile: solr_cloud/Dockerfile
      target: external_zookeeper_docker
```

* [For testing] Manually create the Solr image with external Zookeeper

```
cd lss_solr_configs
export IMAGE_REPO=ghcr.io/hathitrust/full-text-search-cloud
docker build . --file solr8.11.2_files/Dockerfile --target external_zookeeper_docker --tag $IMAGE_REPO:shards-docker
docker image tag shards-docker:latest ghcr.io/hathitrust/full-text-search-cloud:shards-docker
docker image push ghcr.io/hathitrust/full-text-search-cloud:shards-docker
```

#### How to run the application to manage collections and configset

The service to manage collections is defined in the `docker-compose.yml`. 
As it is dependent on Solr, for convenience, it 
is in the same `docker-compose.yml` file. 
Once the `solr_manager` container is up, you can use it to manage any 
collection in any Solr server running in Docker or Kubernetes, 
because it is a Python module that receives the Solr URL
as a parameter. 
You will have to pass the admin password to create collections and upload configsets.

If you start the Solr server in Docker, the admin password is defined in the `security.json` file and it 
is the default password used by Solr (solrRocks).

If you start the Solr server in Kubernetes, the admin password is defined in the secrets.
```
export SOLR_PASSWORD=solrRocks
docker compose -f docker-compose.yml --profile solr_collection_manager up
```

Using `--profile` option in the docker-compose file, you can start up the following services
  * solr1
  * zoo1
  * solr_manager

Read `solr_manager/README.md` to see how to use this module.

#### How to run the application to create the Solr cluster with one collection

Once the Solr server is running, you can use the `solr_collection_manager.py` script to create a collection and upload a configset.

* Build the Docker image for the Solr collection manager

```
docker compose build solr_manager
```

* Start the Solr collection manager service
```
docker compose up -d solr_manager
```

* Run the script to upload a configset.
The `tests/conf.zip` file contains the configuration files for the collection, and it is located in the `solr_manager` 
directory, and it is mounted in the container.

```bash
docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action upload_configset --configset_name core-x --path_configset tests/conf.zip
```

* Run the script to create a collection once the configset is uploaded
```bash
docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action create_collection --name core-x --num_shards 1 --max_shards_per_node 1 --replication_factor 1 --configset_name core-x
```

#### How to index data in Solr 8
To index data in Solr 8, you can use the `indexing_data.sh` script.
To run the script, you will need to pass the following parameters:
* Solr URL, 
* Solr password,
* the path to the folder where the XML files will be extracted, 
* the path to the zip file with the XML files, and 
* The collection name

```bash
export SOLR_PASSWORD=solrRocks
./indexing_data.sh http://localhost:8983 $SOLR_PASSWORD ~/mydata data_sample.zip core-x
```

* To create the collection in full-text search server, use the command below
  * `docker exec solr-lss-dev /var/solr/data/collection_manager.sh`
  * `docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action upload_configset --configset_name core-x --path_configset tests/conf.zip`
  * `docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action create_collection --name core-x --num_shards 1 --max_shards_per_node 1 --replication_factor 1 --configset_name core-x`

* To index data in the full-text search server, use the command below
  * `./indexing_data.sh http://localhost:8983 solr_pass ~/mydata data_sample.zip core-x`


#### How to integrate it in babel-local-dev

Update _docker-compose.yml_ file inside babel directory replacing the service _solr-lss-dev_. Create a new one with the
following specifications

```solr-lss-dev:
    image: ghcr.io/hathitrust/solr-lss-dev:shards-docker
    container_name: solr1
    ports:
     - "8981:8983"
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
    command: solr-foreground -c # Solr command to start the container to make sure the security.json is created
    healthcheck:
      test: [ "CMD", "/usr/bin/curl", "-s", "-f", "http://solr-lss-dev:8983/solr/#/admin/ping" ]
      interval: 30s
      timeout: 10s
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
    networks:
      - solr
    volumes:
      - zoo1_data:/data
    healthcheck:
      test: [ "CMD", "echo", "ruok", "|", "nc", "localhost", "2181", "|", "grep", "imok" ]
      interval: 30s
      timeout: 10s
      retries: 5
    solr_manager:
      build:
        context: solr_manager
        target: runtime
        dockerfile: Dockerfile
        args:
          UID: ${UID:-1000}
          GID: ${GID:-1000}
          ENV: ${ENV:-dev}
          POETRY_VERSION: ${POETRY_VERSION:-1.5.1}
          SOLR_PASSWORD: ${SOLR_PASSWORD:-solr}
          SOLR_USER: ${SOLR_USER:-solrRocks}
          ZK_HOST: ${ZK_HOST:-zoo1:2181}
      env_file:
        - solr_manager/.env
      volumes:
        - .:/app
      stdin_open: true
      depends_on:
        solr-lss-dev:
          condition: service_healthy
      tty: true
      container_name: solr_manager
      networks:
        - solr
      profiles: [ solr_collection_manager ]
```

You might add the following list of volumes to the docker-compose file.

```solr1_data:

  zookeeper1_data:
  zookeeper1_datalog:
  zookeeper1_log:
  zookeeper1_wd:

```

* To start up the application, 
  * docker-compose build 
  * docker-compose up 


## Hosting

The Solr server is hosted in Kubernetes. 

Find [here](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/3163717633/Steps+to+start+up+the+Solr+cluster+in+Kubernetes+and+using+Argo+CD) 
a detail explanation of how the Solr server was set up in Kubernetes

Fulltext search Solr cluster Argocd application:
https://argocd.ictc.kubernetes.hathitrust.org/applications/argocd/fulltext-workshop-solrcloud?resource=

## Resources

### How-to index data using a sample of documents

The sample of data is in `macc-ht-ingest-000.umdl.umich.edu:/htprep/fulltext_indexing_sample/data_sample.zip`

* Download a zip file with a sample of documents to your local environment
`scp macc-ht-ingest-000.umdl.umich.edu:/htprep/fulltext_indexing_sample/data_sample.zip ~/datasets` 

* In your working directory,
  * After starting up the Solr server inside the docker,
  * run the script indexing_data.sh. You will need the admin password for doing that.
  
  ```./indexing_data.sh http://localhost:8983 solr_pass ~/mydata data_sample.zip collection_name`. ```
  
  The script will extract all the XML files inside the Zip file to a destined folder. 
Then, it will index the documents in Solr server. 
The script input parameters are: 
  * solr_url
  * solr password
  * the path to the target folder to extract the files 
  * the path to the zip file with the sample of documents.
  
At the end of this process, your Solr server should have a sample of 150 documents.

**Note**: If in the future we should automatize this process, a service to index documents could be included in the docker-compose. 
You will have to add the data sample to the docker image or download it from a repository. See the example below as a reference

```data_loader:
    build:
      context: ./lss_solr_configs
      dockerfile: ./solr_cloud/Dockerfile
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

### Useful commands

* Command to create core-x collection. 
Recommendation: Pass the instanceDir and the dataDir to the curl command
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

## Deployment and Use

Go to section `How to integrate it in babel-local-dev` to see how to integrate each Solr server into another application.

### Re-Indexing

* To solve the issue below, the solrconfig.xml file was updated to enable the updateLog option.

```ERROR org.apache.solr.cloud.SyncStrategy – No UpdateLog found - cannot sync```

* In the Solr cloud logs with embedded ZooKeeper, you could see the issue below. 
That is more of a warning than error, and 
it appears because we are running only one ZK in standalone mode. More details of this
message [here](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/edit-v2/2661482577).

```Invalid configuration, only one server specified (ignoring)```

### Testing
### Deployment to Production
### Production Indexing
### Production Serving

## Considerations for future modification

### Move to AWS


### Testing


## Links to more background

* [docker solr examples](https://github.com/docker-solr/docker-solr-examples/tree/master/custom-configset): https://github.com/docker-solr/docker-solr-examples/tree/master/custom-configset
* [SolrCloud & Catalog indexing](https://github.com/mlibrary/catalog-browse-indexing/blob/main/docker-compose.yml)
* [SolrCloud + ZooKeeper external server & data persistence](https://github.com/samuelrac/solr-cloud)
* [Our documentation with more information](https://hathitrust.atlassian.net/wiki/spaces/HAT/pages/edit-v2/2661482577)
* [An example of SolrCloud in Catalog](https://github.com/hathitrust/hathitrust_catalog_indexer/blob/main/README.md)
* [How to set up Solr cloud cluster in Kubernetes](https://apache.github.io/solr-operator/docs/solr-cloud/solr-cloud-crd.html#prometheus-exporter)
