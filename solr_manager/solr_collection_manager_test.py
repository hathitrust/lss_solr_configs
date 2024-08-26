from unittest.mock import Mock
from unittest.mock import patch
import unittest

import pytest
import os

import requests

from solr_manager.solr_collection_manager import SolrCollectionManager

SOLR_HOST_NAME = "localhost"

"""These tests follow the Arrange-Act-Assert (AAA) pattern"""

@pytest.fixture
def solr_manager():

    solr_url = f"http://{SOLR_HOST_NAME}:8983"

    solr_user = os.getenv("SOLR_USER")
    solr_pass = os.getenv("SOLR_PASSWORD")

    return SolrCollectionManager(solr_url, solr_user, solr_pass)

@patch('requests.get')
def test_ping(mock_get, solr_manager):

    # Arrange
    # Mock the response
    mock_response = Mock()
    mock_response.raise_for_status.return_value = None
    mock_get.return_value = mock_response

    # Act
    result = solr_manager.ping()

    # Assert
    mock_get.assert_called_once_with(f'{solr_manager.solr_url}/solr/', auth=solr_manager.auth)
    unittest.TestCase().assertTrue(result)

@patch('requests.get')
def test_ping_failure(mock_get, solr_manager):
    # Arrange
    # Mock the response to raise an HTTPError
    mock_get.side_effect = requests.exceptions.HTTPError

    # Act
    result = solr_manager.ping()

    # Assert
    mock_get.assert_called_once_with(f'{solr_manager.solr_url}/solr/', auth=solr_manager.auth)
    unittest.TestCase().assertFalse(result)

@patch('requests.get')
def test_create_collection(mock_get, solr_manager):
    mock_response = {
        "responseHeader": {
            "status": 0,
            "QTime": 1
        }
    }
    mock_get.return_value.json.return_value = mock_response

    response = solr_manager.create_collection("test_collection")
    assert response == mock_response
    mock_get.assert_called_once_with(
        f"http://{SOLR_HOST_NAME}:8983/solr/admin/collections",
        params={
            'action': 'CREATE',
            'name': 'test_collection',
            'numShards': 1,
            'replicationFactor': 1,
            'collection.configName': None,
            'maxShardsPerNode': 1
        },
        auth=solr_manager.auth
    )

@patch('requests.put')
def test_upload_configset(mock_put, solr_manager):
    mock_response = {
        "responseHeader": {
            "status": 0,
            "QTime": 1
        }
    }
    configset_name = "test_configset"
    mock_put.return_value.json.return_value = mock_response
    path_config_set = f"{os.getcwd()}/solr_files/conf.zip"
    response = solr_manager.upload_configset(configset_name, path_config_set)
    assert response == mock_response

@patch('requests.delete')
def test_delete_configset(mock_delete, solr_manager):
    # Mock the response
    mock_response = Mock()
    mock_response.json.return_value = {'responseHeader': {'status': 0}}
    mock_delete.return_value = mock_response

    configset_name = "test_configset"
    # Act
    response = solr_manager.delete_configset(configset_name)

    # Assert
    mock_delete.assert_called_once_with(f'{solr_manager.solr_url}/api/cluster/configs/{configset_name}',
                                        auth=solr_manager.auth)
    assert response == {'responseHeader': {'status': 0}}

@patch('requests.get')
def test_create_collection_already_exist(mock_get, solr_manager):
    collection_name = "test_collection"
    mock_response = {
        "responseHeader": {
            "status": 400,
            "msg": f"collection already exists: {collection_name}"
        }
    }
    mock_get.return_value.json.return_value = mock_response

    response = solr_manager.create_collection("test_collection")
    assert response == mock_response

    mock_get.assert_called_once_with(
        f"http://{SOLR_HOST_NAME}:8983/solr/admin/collections",
        params={
            'action': 'CREATE',
            'name': collection_name,
            'numShards': 1,
            'replicationFactor': 1,
            'collection.configName': None,
            'maxShardsPerNode': 1
        },
        auth=solr_manager.auth
    )

@patch('requests.get')
def test_delete_collection(mock_get, solr_manager):
    mock_response = {
        "responseHeader": {
            "status": 0,
            "QTime": 1
        }
    }
    mock_get.return_value.json.return_value = mock_response

    response = solr_manager.delete_collection("test_collection")
    assert response == mock_response
    mock_get.assert_called_once_with(
        f"http://{SOLR_HOST_NAME}:8983/solr/admin/collections",
        params={
            'action': 'DELETE',
            'name': 'test_collection'
        },
        auth=solr_manager.auth
    )


@patch('requests.get')
def test_list_collections(mock_get, solr_manager):
    mock_response = {
        "responseHeader": {
            "status": 0,
            "QTime": 1
        },
        "collections": ["collection1", "collection2"]
    }
    mock_get.return_value.json.return_value = mock_response

    response = solr_manager.list_collections()
    assert response == mock_response
    mock_get.assert_called_once_with(
        f"http://{SOLR_HOST_NAME}:8983/solr/admin/collections",
        params={
            'action': 'LIST'
        },
        auth=solr_manager.auth
    )
