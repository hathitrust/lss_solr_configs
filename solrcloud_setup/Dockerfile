#FROM --platform=$BUILDPLATFORM solr:8.11.2 AS indexer
FROM solr:8.11.2

#RUN apt-get update && apt-get install -y zip unzip

COPY --chown=solr:solr conf /opt/solr/core-x

# COPY --chown=solr:solr conf /var/solr/data/core-x

COPY --chown=solr:solr lib /var/solr/lib

COPY --chown=solr:solr --chmod=0755 init_files/solr_init.sh /usr/local/bin/solr_init.sh

COPY --chown=solr:solr solr_json_documents /var/solr/data

COPY --chown=solr:solr --chmod=0755 collection_manager.sh /var/solr/data/collection_manager.sh

#ENV SOLR_OPTS "-XX:-UseLargePages -Djetty.host=127.0.0.1 -Dlog4j2.formatMsgNoLookups=true"

RUN /usr/local/bin/solr_init.sh
