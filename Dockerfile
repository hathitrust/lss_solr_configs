#SOLR_HOME directory: /var/solr
FROM solr:8.11.2

ENV SOLR_JAVA_MEM="-Xms1024m -Xmx1024m"
ENV SOLR_HEAP="1024m"

ENV SOLR_DATA_PATH=/var/solr/data
#ENV SOLR_DATA_PATH=solrdata

#USER root

#Create the directory with Solr data
#RUN mkdir -p $SOLR_DATA_PATH

#All cores sharing solr.xml
#COPY --chown=solr:solr solr/solr.xml $SOLR_DATA_PATH

#Create core-x
#COPY --chown=solr:solr solr/conf ${SOLR_DATA_PATH}/core-x/conf
#COPY --chown=solr:solr solr/lib ${SOLR_DATA_PATH}/core-x/lib
#COPY --chown=solr:solr data ${SOLR_DATA_PATH}/core-x/data/
#COPY --chown=solr:solr solr/core-x.properties ${SOLR_DATA_PATH}/core-x/core.properties
#USER solr

COPY --chown=solr:solr solrdata /var/solr/data