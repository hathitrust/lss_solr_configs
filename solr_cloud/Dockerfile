FROM solr:8.11.4 AS common

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

# Copy the required files to the image, lib and conf files
COPY --chown=solr:solr ./lib /var/solr/lib
COPY --chown=solr:solr ./conf /opt/solr/core-x


#=======================================================
FROM common AS external_zookeeper_docker
# any steps specific to building the image with external zookeeper
# authentication is enabled in the solr container
COPY --chown=solr:solr ./security.json /opt/solr/security.json

COPY --chown=solr:solr --chmod=0755 ./init_files/solr_init.sh /usr/bin/solr_init.sh

# Run this script to start solr as an entrypoint to configure the container to run as an executable
ENTRYPOINT ["/usr/bin/solr_init.sh"]


