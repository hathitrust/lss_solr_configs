#SOLR_HOME directory: /var/solr
FROM solr:8.11.2

USER root
RUN apt-get update && apt-get install -y curl

ENV SOLR_JAVA_MEM="-Xms1024m -Xmx1024m"
ENV SOLR_HEAP="1024m"

ENV SOLR_DATA_PATH=solrdata

#Create the directory with Solr data
RUN mkdir -p $SOLR_DATA_PATH

COPY --chown=solr:solr solr_json_documents/core-data.json $SOLR_DATA_PATH

COPY --chown=solr:solr solrdata /var/solr/data

USER solr