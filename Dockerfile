FROM solr:8

#Check if we should load in a different path
COPY --chown=solr:solr . /opt/lss_solr_configs
COPY --chown=solr:solr ./lib /opt/solr/server/solr/lib

COPY --chown=solr:solr ./lss-dev/core-x /var/solr/data/core-x
COPY --chown=solr:solr ./lss-dev/core-y /var/solr/data/core-y
