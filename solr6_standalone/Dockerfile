FROM solr:6.6.6-alpine

COPY --chown=solr:solr . /opt/lss_solr_configs
COPY --chown=solr:solr ./lib /opt/solr/server/solr/lib
COPY --chown=solr:solr ./lss-dev/core-x /opt/solr/server/solr/core-x
COPY --chown=solr:solr ./lss-dev/core-y /opt/solr/server/solr/core-y
