FROM solr:8.11.2 AS common

# any steps everything needs

#Copy a batch of xml files to the container
#COPY --chown=solr:solr ./data_sample /var/solr/data/data_sample
COPY --chown=solr:solr ./solr8.11.2_files/lib /var/solr/lib
#COPY --chown=solr:solr --chmod=0755  ./indexing_data.sh /usr/local/bin/indexing_data.sh

#=======================================================
FROM common AS standalone
# any steps specific to building the standalone image

ENV SOLR_JAVA_MEM="-Xms1024m -Xmx1024m"
ENV SOLR_HEAP="1024m"

ENV SOLR_DATA_PATH=solrdata

COPY --chown=solr:solr ./solr8.11.2_files/conf /var/solr/data/core-x/conf

COPY --chown=solr:solr ./solr8.11.2_files/solr_standalone_mode/core.properties /var/solr/data/core-x

#======================DONE=================================
FROM common AS embedded_zookeeper
# any steps specific to building the image with embedded zookeeper

COPY --chown=solr:solr ./solr8.11.2_files/conf /opt/solr/core-x

COPY --chown=solr:solr --chmod=0755  ./solr8.11.2_files/solrCloud_embedded_zooKeeper/init_files/solr_init.sh /usr/local/bin/solr_init.sh

COPY --chown=solr:solr --chmod=0755 ./solr8.11.2_files/solrCloud_embedded_zooKeeper/collection_manager.sh /var/solr/data/collection_manager.sh

#ENV SOLR_OPTS "-XX:-UseLargePages -Djetty.host=127.0.0.1 -Dlog4j2.formatMsgNoLookups=true"

RUN /usr/local/bin/solr_init.sh

#=======================================================
FROM common AS external_zookeeper
# any steps specific to building the image with external zookeeper

COPY --chown=solr:solr ./solr8.11.2_files/conf /opt/solr/core-x

COPY --chown=solr:solr ./solr8.11.2_files/conf /var/solr/data/core-x

COPY --chown=solr:solr --chmod=0755 ./solr8.11.2_files/solrCloud_external_zooKeeper/init_files/solr_init.sh /usr/bin/solr_init.sh

COPY --chown=solr:solr --chmod=0755 ./solr8.11.2_files/solrCloud_external_zooKeeper/collection_manager.sh /var/solr/data/collection_manager.sh

ENTRYPOINT ["/usr/bin/solr_init.sh"]
