FROM solr:6.6.6-alpine

COPY . /opt/lss_solr_configs
COPY ./lib /opt/solr/server/solr/lib
COPY ./lss-dev/core-x /opt/solr/server/solr/core-x
COPY ./lss-dev/core-y /opt/solr/server/solr/core-y
