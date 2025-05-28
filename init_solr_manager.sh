#!/usr/bin/env bash

if [ -f "solr_manager/.env" ]; then
  echo "🌎 solr_manager/.env exists. Leaving alone"
else
  echo "🌎 solr_manager/.env does not exist. Copying solr_manager/.env-example to solr_manager/.env"
  cp solr_manager/env.example solr_manager/.env

  YOUR_UID=`id -u`
  YOUR_GID=`id -g`
  echo "🙂 Setting your UID ($YOUR_UID) and GID ($YOUR_UID) in .env"
  docker run --rm -v ./solr_manager/.env:/solr_manager/.env alpine echo "$(sed s/YOUR_UID/$YOUR_UID/ solr_manager/.env)" > solr_manager/.env
  docker run --rm -v ./solr_manager/.env:/solr_manager/.env alpine echo "$(sed s/YOUR_GID/$YOUR_GID/ solr_manager/.env)" > solr_manager/.env
fi

echo "🚢 Run containers"
docker compose -f docker compose.yml --profile solr_collection_manager up
