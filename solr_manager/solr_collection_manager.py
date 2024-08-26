import requests
import zipfile
import shutil
import os
from requests.auth import HTTPBasicAuth
import argparse


class SolrCollectionManager:
    """
    A class to manage Solr collections and configsets.

    The class uses requests to interact with the Solr collections API.
    Https://solr.apache.org/guide/8_2/collections-api.html

    Collections API is provided to allow you to control your cluster, including the collections, shards,
    replicas, backups, leader election, and other operations needs.
    Each collection uses a single solrconfig.xml and schema.xml file.


    Attributes:
    -----------
    solr_url : str
        The URL of the Solr server.
    solr_admin_url : str
        The URL for Solr admin collections API.
    auth : HTTPBasicAuth or None
        The authentication object for Solr, if provided.
        To create collections or configset, the user must have the required permissions: solr admin user.

    Methods:
    --------
    ping():
        Checks if the Solr server is up and running.
    Create_collection(name, num_shards=1, replication_factor=1, configset_name=None, maxShardsPerNode=1):
        Create a new collection in Solr.
    Upload_configset(name_configset, path_configset):
        Upload configset to Solr.
    Delete_configset(configset_name):
        Delete a configset from Solr.
    Delete_collection(name):
        Delete a collection from Solr.
    List_collections():
        Lists all collections in Solr.
    """

    def __init__(self, solr_url, solr_user=None, solr_pass=None):
        self.solr_url = solr_url
        self.solr_admin_url = f"{solr_url}/solr/admin/collections"
        self.auth = HTTPBasicAuth(solr_user, solr_pass) if solr_user and solr_pass else None

    def ping(self):
        """
        Check if the Solr server is up and running.
        :param self:
        :return: True if the server is up, False otherwise.
        """

        try:
            response = requests.get(f'{self.solr_url}/solr/', auth=self.auth)
            response.raise_for_status()
            return True
        except requests.exceptions.HTTPError as e:
            print(f"Error: {e}")
            return False

    def create_collection(self, name, num_shards=1, replication_factor=1, configset_name=None, max_shards_per_node=1):
        """
        Create a new collection in Solr.
        :param name: Name of the collection.
        :param num_shards: Number of shards.
        :param replication_factor: Replication factor.
        :param configset_name: Name of the configset.
        :param max_shards_per_node: Maximum number of shards per node.
        :return: JSON response.
        """

        input_params = {
            'action': 'CREATE',
            'name': name,
            'numShards': num_shards,
            'replicationFactor': replication_factor,
            'collection.configName': configset_name,
            'maxShardsPerNode': max_shards_per_node
        }

        response = requests.get(self.solr_admin_url, params=input_params, auth=self.auth)
        return response.json()

    def upload_configset(self, name_configset, path_configset):
        """
        Upload a configset to Solr.
        :param name_configset: Name of the configset.
        :param path_configset: Path to the folder with the configset.
        :return: JSON response.
        """
        url = f"{self.solr_url}/api/cluster/configs/{name_configset}"

        headers = {
            "Content-Type": "application/octet-stream"
        }

        if not os.path.exists(path_configset):
            raise FileNotFoundError(f"File not found: {path_configset}")

        zip_path = path_configset if zipfile.is_zipfile(path_configset) else None

        # The input parameter is a directory, then we need to create a zip file
        if not zip_path and os.path.isdir(path_configset):
            zip_path = f"{path_configset}.zip"
            shutil.make_archive(path_configset, 'zip', path_configset)

        with open(zip_path, 'rb') as file:
            response = requests.put(url, headers=headers, data=file, auth=self.auth)

            print(f"Uploaded configset: {name_configset}")
        return response.json()

    def delete_configset(self, configset_name):
        url = f"{self.solr_url}/api/cluster/configs/{configset_name}"
        response = requests.delete(url, auth=self.auth)
        response.raise_for_status()  # Raise an exception for HTTP errors
        return response.json()

    def delete_collection(self, name):
        input_params = {
            'action': 'DELETE',
            'name': name
        }
        response = requests.get(self.solr_admin_url, params=input_params, auth=self.auth)
        return response.json()

    def list_collections(self):
        input_params = {
            'action': 'LIST'
        }
        response = requests.get(self.solr_admin_url, params=input_params, auth=self.auth)
        return response.json()


def main():
    """
        Main function to handle command-line arguments and perform actions on Solr collections.

        Command-line Arguments:
        -----------------------
        --solr_url : str
            The URL of the Solr server (required).
        --action : str
            The action to perform (required).
            Possible values: 'upload_configset', 'create_collection', 'list_collections',
            'delete_collection', 'delete_configset'.
        --name : str
            The name of the collection (optional, required for 'create_collection' and 'delete_collection').
        --num_shards : int
            The number of shards (optional, default is 1, used in 'create_collection').
        --replication_factor : int
            The replication factor (optional, default is 3, used in 'create_collection').
        --maxShardsPerNode : int
            The maximum number of shards per node (optional, default is 1, used in 'create_collection').
        --configset_name : str
            The name of the configset (optional, used in 'create_collection' and 'upload_configset').
        --path_configset : str
            The path to the configset (optional, used in 'upload_configset').

        Example Usage:
        --------------
        python solr_collection_manager.py --solr_url http://localhost:8983 --action create_collection --name my_collection --num_shards 2 --replication_factor 2 --configset_name my_configset
    """

    # parameters
    parser = argparse.ArgumentParser(description='Solr Collection Manager')
    parser.add_argument('--solr_url', type=str, help='Solr URL', required=True)

    parser.add_argument('--action', type=str, help='Action to perform', required=True)

    # Collection parameters
    parser.add_argument('--name', type=str, help='Name of the collection', required=False)
    parser.add_argument('--num_shards', type=int, help='Number of shards', required=False, default=1)
    parser.add_argument('--replication_factor', type=int, help='Replication factor', required=False,
                        default=3)
    # Defining maxShardsPerNode sets a limit on the number of replicas the CREATE action will spread to each node.
    parser.add_argument('--max_shards_per_node', type=int, help='Number of shards', required=False,
                        default=1)

    # Configset parameters
    parser.add_argument('--configset_name', type=str, help='Name of the configset',
                        required=False, default=None)
    parser.add_argument('--path_configset', type=str, help='Path to the configset',
                        required=False, default=None)

    # Actions
    args = parser.parse_args()

    manager = SolrCollectionManager(args.solr_url, os.getenv("SOLR_USER"), os.getenv("SOLR_PASSWORD"))

    # Define a dictionary to map actions to their corresponding functions and parameters
    actions = {
        "upload_configset": {
            "function": manager.upload_configset,
            "params": {
                "name_configset": args.configset_name,
                "path_configset": args.path_configset
            }
        },
        "delete_configset": {
            "function": manager.delete_configset,
            "params": {
                "name_configset": args.configset_name
            }
        },
        "create_collection": {
            "function": manager.create_collection,
            "params": {
                "name": args.name,
                "num_shards": args.num_shards,
                "replication_factor": args.replication_factor,
                "configset_name": args.configset_name,
                "max_shards_per_node": args.max_shards_per_node
            }
        },
        "list_collections": {
            "function": manager.list_collections,
            "params": {}
        },
        "delete_collection": {
            "function": manager.delete_collection,
            "params": {
                "name": args.name
            }
        }
    }

    # Example action
    action = args.action

    # Use the match statement to handle each case
    match action:
        case "upload_configset" | "create_collection" | "list_collections" | "delete_collection":
            func = actions[action]["function"]
            params = actions[action]["params"]
            result = func(**params)
            print(result)
        case _:
            print("Unknown action")


# Example usage
if __name__ == "__main__":

    main()