#SOLR_HOME directory: /var/solr
FROM solr:8.11.2

USER root
RUN apt-get update && apt-get install -y curl

ENV SOLR_JAVA_MEM="-Xms1024m -Xmx1024m"
ENV SOLR_HEAP="1024m"

#ENV SOLR_DATA_PATH=/var/solr/data
ENV SOLR_DATA_PATH=solrdata

#Create the directory with Solr data
RUN mkdir -p $SOLR_DATA_PATH

#All cores sharing solr.xml
#COPY --chown=solr:solr solr_to_delete/solr.xml $SOLR_DATA_PATH

#Create core-x
#COPY --chown=solr:solr solr_to_delete/conf ${SOLR_DATA_PATH}/core-x/conf
#COPY --chown=solr:solr solr_to_delete/lib ${SOLR_DATA_PATH}/core-x/lib
#COPY --chown=solr:solr data ${SOLR_DATA_PATH}/core-x/data/
#COPY --chown=solr:solr solr_to_delete/core-x.properties ${SOLR_DATA_PATH}/core-x/core.properties
COPY --chown=solr:solr solr_json_documents/core-data.json $SOLR_DATA_PATH


COPY --chown=solr:solr solrdata /var/solr/data

USER solr