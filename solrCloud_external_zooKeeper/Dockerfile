#FROM solr:8.11.2
FROM --platform=$BUILDPLATFORM solr:8.11 AS indexer

ENV SOLR_AUTH_TYPE="basic"
ENV SOLR_AUTHENTICATION_OPTS="-Dbasicauth=solr:SolrRocks"
ENV SOLR_OPTS="-Denable.packages=true"

COPY --chown=solr:solr solr8.11.2_files/conf /opt/solr/core-x

COPY --chown=solr:solr solr8.11.2_files/conf /var/solr/data/core-x

COPY --chown=solr:solr solr8.11.2_files/lib /var/solr/lib

COPY --chown=solr:solr init_files/security.json /var/solr/data/security.json
COPY --chown=solr:solr --chmod=0755 init_files/solr_init.sh /usr/bin/solr_init.sh

COPY --chown=solr:solr solr8.11.2_files/solr_json_documents /var/solr/data
COPY --chown=solr:solr --chmod=0755 collection_manager.sh /var/solr/data/collection_manager.sh
COPY --chown=solr:solr --chmod=0755 env.example /var/solr/data/env.example

#COPY --chown=solr:solr --chmod=0755 ./full-text-search_data/collection_manager.sh /tmp
#COPY --chown=solr:solr --chmod=0755 ./full-text-search_data/core-data.json /tmp
#COPY --chown=solr:solr --chmod=0755 solrcloud_setup/collection_manager.sh /var/solr/data/collection_manager.sh

#RUN mkdir /tmp/full-text-data && \
#    ln -s /tmp/full-text-data /var/solr/data/core-x/data && \
#    start-local-solr && \
#    bash /var/solr/data/collection_manager.sh && \
#    stop-local-solr

ENTRYPOINT ["/usr/bin/solr_init.sh"]

#COPY --chown=solr:solr ./solrcloud_setup/conf /var/solr/data/core-x
#COPY --chown=solr:solr /tmp/full-text-data /var/solr/data/core-x/data
