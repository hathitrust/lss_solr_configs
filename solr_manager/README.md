<br/>
  <p align="center">
    lss_solr_configs - Solr Manager
    <br/>
    <br/>
    <a href="https://github.com/hathitrust/lss_solr_configs/issues">Report Bug</a>
    -
    <a href="https://github.com/hathitrust/lss_solr_configs/issues">Request Feature</a>
  </p>


This `README.md` file provides a comprehensive guide to the `solr_manager` application, covering installation, configuration, usage, testing, and troubleshooting.

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
* [Troubleshooting](#troubleshooting)
  * [Common Issues](#common-issues)
  * [Checking Solr Status](#checking-solr-status)

## About The Project

This project is a Python application designed to manage Solr collections. 
It provides functionalities to create, delete, list, and upload and delete configsets to Solr collections.

## Built With
It is based on the [requests](https://docs.python-requests.org/en/latest/) library to interact 
with the Solr collections [API] (https://solr.apache.org/guide/8_2/collections-api.html).

The application runs in a docker container, and it is based on the 
[python:3.11.0a7-slim-buster](https://hub.docker.com/_/python) image. In the docker-compose file, a Solr container with three nodes and 3 embedded zookeeper are also started.
Their dependencies are managing to use [poetry](https://python-poetry.org/). 

## Phases
The project is divided into the following phases:
1. **Phase 1**: 
   * Create a Python application to manage Solr collections.
   * Implement functionalities to create, delete, list, and upload configsets.
   * Write tests for the application.
   * Create a Docker container for the application.
   * Implement a CI/CD pipeline for the project.
   * Write documentation for the application.
2. **Phase 2**:
   * Implement additional functionalities for the application.
   * Add support for managing Solr cores.
   * Enhance the application's error handling.
   * Improve the application's performance.
   * Update the documentation with new features.

## Project Set Up

1. Clone the repository:
    ```sh
    git clone git@github.com:hathitrust/lss_solr_configs.git
    cd solr_manager
    ```

2. Build the Docker image:
    ```docker-compose build solr_manager```

3. Start the container:
    ```
    docker-compose up -d solr_manager
    ```
4. [Recommendation] Run the script `init_solr_manager.sh` to start the application and set up the environment variables.
    ```
    ./init_solr_manager.sh
    ```
Ensure the following environment variables are set:
- `SOLR_USER`: Solr username
- `SOLR_PASS`: Solr password

You can set these variables in a `.env` file in solr_manager directory:
```env
SOLR_USER=your_solr_username
SOLR_PASS=your_solr_password
```

### Prerequisites
- Docker

### Installation

1. Clone the repo
   ``` git clone git@github.com:hathitrust/lss_solr_configs.git```

2. Set up development environment with poetry
    
    ``cd solr_manager``
  In your workdir,
  
      * `poetry init` # It will set up your local virtual environment and repository details
      * `poetry env use python` # To find the virtual environment directory, created by poetry
      * `source ~/lss-solr-configs-OUr1hOm6-py3.11/bin/activate` # Activate the virtual environment
      * `poetry add pytest` # Add dependencies


### Creating A Pull Request

1. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
2. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
3. Squash your commits (`git rebase -i HEAD~n` where n is the number of commits you want to squash)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Content Structure

### Project Structure

This is the main structure of the python application.
```
solr_manager/
├── Dockerfile
├── README.md
├── docker-compose.yml
├── pyproject.toml
├── poetry.lock
├── .env
├── solr_manager/
│   ├── __init__.py
│   ├── solr_collection_manager.py
│   ├── solr_collection_manager_test.py
└── solr_files/
    └── test_configset.zip
init_solr_manager.sh
```

As this project requires a Solr server to run, the `docker-compose.yml` file starts a 3 Solr containers
with 3 embedded zookeepers. For that reason, the solr_manager/docker-compose.yml file depends on some files inside 
the solr8.11.2_files directory, such as, the Dockerfile and solrCloud_embedded_zookeeper directory.

Inside the solr_files directory, there is a test_configset.zip file that is used to test the upload_configset functionality.

### Design

The application is designed to interact with the Solr collections API to manage Solr collections using 
the requests python library. 
The [pysolr package](https://pypi.org/project/pysolr/) was tested as a main alternative to manage Solr collections and
configsets. We decided not used in the final version of the application because:
* the last release was in 2020
* it seems an additional layer of abstraction that we don't need
* to use it you should understand the Solr API anyway and also the pysolr package
* the requests library brings more flexible and easy to use
* use requests library is a more transparent way to interact with the Solr API

Only the `solr_collection_manager.py` file is used to manage Solr collections and configs. 
In `solr_collection_manager_test.py` file, there are tests for the functionalities implemented in
`solr_collection_manager.py`.

### Functionality
The application provides the following functionalities:
- Create a collection
- Delete a collection
- List collections
- Upload a configset
- Delete a configset


## Usage

### Create a Collection
```
docker exec -it solr_manager python solr_collection_manager.py --solr_url <solr_url> --action create_collection --name <collection_name> --replication_factor <replication_factor>
```

Example:
```docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action create_collection --name new_collection --replication_factor 1```

The script that creates a collection also accepts the following optional arguments:
- `--num_shards`: Number of shards (default: 1)
- `--replication_factor`: Replication factor (default: 1)
- `--configset_name`: Configset name (default: _default)
- `--max_shards_per_node`: Maximum number of shards per node (default: 1)

In the command below, 
you will see how to use the different parameters to create collections with different configurations:

```
docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action create_collection \
--name new_collection --num_shards 1 --max_shards_per_node 1 --replication_factor 1 --configset_name conf
```

The collection with the name `new_collection` will be created using the already created configset `conf` and the 
collection will be distributed in two shards considering that 3 shards per node are allowed.

The script will return an error message:
* if the collection already exists
* if the configset does not exist
* if the Solr server is not running

### Delete a Collection
```
docker exec -it solr_manager python solr_collection_manager.py --solr_url <solr_url> --action delete_collection --name <collection_name>
```

The script will return an error message:
* if the collection does not exist
* if the Solr server is not running

Example:
```docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action delete_collection --name new_collection```

### List Collections
```
docker exec -it solr_manager python solr_collection_manager.py --solr_url <solr_url> --action list_collections
```

### Upload Configset

The configfile directory must contain the files: `solr.xml`, `solrconfig.xml` and `schema.xml`.

```
docker exec -it solr_manager python solr_collection_manager.py --solr_url <solr_url> --action upload_configset --name <configset_name> --path <path_to_configset>
```

Example:
```docker exec -it solr_manager python solr_collection_manager.py --solr_url http://solr1:8983 --action upload_configset --configset_name new_configset --path_configset tests/conf.zip```

The script that uploads a configset will return an error message:
* if the configset already exists.
* if the configset does not contain the required files. ==> Can't find resource 'solrconfig.xml' 
* if the Solr server is not running.

### Delete Configset
```
docker exec -it solr_manager python solr_collection_manager.py --solr_url <solr_url> --action delete_configset --name <configset_name>
```

## Tests

``` 
docker exec -it solr_manager python -m pytest
```

## Hosting
- This section should outline the ideal environment for hosting this application and it's intention.

## Resources

## Troubleshooting
### Common Issues
- **Connection Errors**: Ensure the Solr server is running and accessible.
- **JSON Decode Errors**: Verify that the Solr server is returning valid JSON responses.

### Checking Solr Status
To check if Solr is running inside the container:
```
docker exec -it solr_manager curl 'http://solr1:8983/solr/admin/collections?action=LIST'
```