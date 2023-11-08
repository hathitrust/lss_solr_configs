FROM --platform=$BUILDPLATFORM solr:8.11.2 AS indexer
#FROM solr:8.11.2

COPY --chown=solr:solr solr8.11.2_files/conf /opt/solr/core-x

COPY --chown=solr:solr solr8.11.2_files/lib /var/solr/lib

COPY --chown=solr:solr --chmod=0755 init_files/solr_init.sh /usr/local/bin/solr_init.sh

COPY --chown=solr:solr solr8.11.2_files/solr_json_documents /var/solr/data

COPY --chown=solr:solr --chmod=0755 collection_manager.sh /var/solr/data/collection_manager.sh

#ENV SOLR_OPTS "-XX:-UseLargePages -Djetty.host=127.0.0.1 -Dlog4j2.formatMsgNoLookups=true"

RUN /usr/local/bin/solr_init.sh
