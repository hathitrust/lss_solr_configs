FROM solr:8.11.2

ENV SOLR_AUTH_TYPE="basic"
ENV SOLR_AUTHENTICATION_OPTS="-Dbasicauth=solr:SolrRocks"
ENV SOLR_OPTS="-Denable.packages=true"

#RUN apt-get update && apt-get install -y zip unzip

COPY --chown=solr:solr conf /core-x

COPY --chown=solr:solr conf /var/solr/data/core-x

COPY --chown=solr:solr lib /var/solr/lib

COPY --chown=solr:solr init_files/security.json /var/solr/data/security.json
COPY --chown=solr:solr --chmod=0755 init_files/solr_init.sh /usr/bin/solr_init.sh

COPY --chown=solr:solr solr_json_documents /var/solr/data

COPY --chown=solr:solr --chmod=0755 collection_manager.sh /var/solr/data/collection_manager.sh

ENTRYPOINT ["/usr/bin/solr_init.sh"]

#ENTRYPOINT ["/var/solr/data/collection_manager.sh"]
