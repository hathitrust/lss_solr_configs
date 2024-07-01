FROM solr:8.11.2 AS common

# Define the authentication type
ENV SOLR_AUTH_TYPE="basic"
ENV SOLR_AUTHENTICATION_OPTS="-Dbasicauth=solr:SolrRocks"

# -Dsolr.security.json= Let's solr know the location of the security.json file
# -Denable.packages=true Enables the use of the packages feature
# -Dsolr.cloud.client.stallTime=30000 Sets the time to wait for the connection to the zookeeper
# -XX:-UseLargePages Disables the use of large pages, It gets rid of "shared memory" warnings
# on Solr startup => https://solr.apache.org/guide/solr/latest/deployment-guide/docker-faq.html
ENV SOLR_OPTS="-Denable.packages=true -Dsolr.cloud.client.stallTime=30000 -Dsolr.security.json=/opt/solr/security.json \
-XX:-UseLargePages"

COPY --chown=solr:solr ./solr8.11.2_files/lib /var/solr/lib

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

COPY --chown=solr:solr ./solr8.11.2_files/security.json /opt/solr/security.json

COPY --chown=solr:solr --chmod=0755  ./solr8.11.2_files/solrCloud_embedded_zooKeeper/init_files/solr_init.sh /usr/bin/solr_init.sh

RUN /usr/bin/solr_init.sh

#=======================================================
FROM common AS external_zookeeper
# any steps specific to building the image with external zookeeper

COPY --chown=solr:solr ./solr8.11.2_files/conf /opt/solr/core-x

COPY --chown=solr:solr ./solr8.11.2_files/security.json /opt/solr/security.json

COPY --chown=solr:solr --chmod=0755 ./solr8.11.2_files/solrCloud_external_zooKeeper/init_files/solr_init.sh /usr/bin/solr_init.sh

COPY --chown=solr:solr --chmod=0755 ./solr8.11.2_files/solrCloud_external_zooKeeper/collection_manager.sh /var/solr/data/collection_manager.sh

# Run this script to start solr as an entrypoint to configure the container to run as an executable
ENTRYPOINT ["/usr/bin/solr_init.sh"]
