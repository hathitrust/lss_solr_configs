FROM solr:9.10.1 AS common

# Define the authentication type
ENV SOLR_AUTH_TYPE="basic"
ENV SOLR_AUTHENTICATION_OPTS="-Dbasicauth=solr:solrRocks"

# Solr 9 enables a Java Security Manager sandbox by default (deprecated upstream, to be removed in a
# future Solr release - see the "Security Manager is deprecated" startup warning). Its default policy
# only grants filesystem read access to Solr's own known directories, not our custom ./lib dir copied to
# /var/solr/lib - verified: with it enabled, core creation fails with
# "access denied (java.io.FilePermission /var/solr/data/../lib read)" as soon as the <lib> directive
# (needed for the UMich custom filters) is processed. Disabled here rather than maintaining a custom
# java.security.policy grant, since this is an internal offline-batch cluster, not a multi-tenant/
# untrusted-configset deployment the sandbox is meant to protect.
ENV SOLR_SECURITY_MANAGER_ENABLED="false"

# -Dsolr.security.json= Let's solr know the location of the security.json file
# -Denable.packages=true Enables the use of the packages feature, so we do not need to
# add SOLR_MODULES=analysis-extra to the docker-compose.yml or to the Kubernetes manifest.
# -Dsolr.cloud.client.stallTime=30000 Sets the time to wait for the connection to the zookeeper
# -XX:-UseLargePages Disables the use of large pages, It gets rid of "shared memory" warnings
# on Solr startup => https://solr.apache.org/guide/solr/latest/deployment-guide/docker-faq.html
# -Dsolr.config.lib.enabled=true Solr 9 disables <lib/> directives in solrconfig.xml/schema.xml by default
# (security hardening); our configset relies on <lib> to load the UMich custom filters and analysis-extras
# ICU jars, so this must stay enabled. Verified: without it, core creation fails with
# "Unable to create core ... Caused by: solr.ICUTokenizerFactory" since the <lib> tags are silently ignored.
ENV SOLR_OPTS="-Denable.packages=true -Dsolr.cloud.client.stallTime=30000 -Dsolr.security.json=/opt/solr/security.json \
-Dsolr.config.lib.enabled=true -XX:-UseLargePages"

# analysis-extras is needed for the ICU folding filter, scripting is needed for the JavaScript update processor.
ENV SOLR_MODULES=analysis-extras

# Add the UMich custom filters jar to the image, and set ownership to solr:solr so Solr can read it
USER root
RUN curl -fL \
    -o /opt/solr/modules/analysis-extras/lib/umich-solr-extensions.jar \
    https://github.com/mlibrary/umich-lib-solr-extensions/releases/download/v1.1/umich-solr-extensions.jar \
    && chown solr:solr /opt/solr/modules/analysis-extras/lib/umich-solr-extensions.jar

# Add HTPostingsFormat.jar to the image, and set ownership to solr:solr so Solr can read it
RUN curl -fL \
    -o /opt/solr/modules/analysis-extras/lib/HTPostingsFormat.jar \
    https://github.com/hathitrust/lss_java_code/releases/download/v1.1/HTPostingsFormat.jar \
    && chown solr:solr /opt/solr/modules/analysis-extras/lib/HTPostingsFormat.jar
USER solr

# Copy the required conf files to the image
COPY --chown=solr:solr ./conf /opt/solr/core-x

#=======================================================
FROM common AS external_zookeeper_docker
# any steps specific to building the image with external zookeeper
# authentication is enabled in the solr container
COPY --chown=solr:solr ./security.json /opt/solr/security.json

COPY --chown=solr:solr --chmod=0755 ./init_files/solr_init.sh /usr/bin/solr_init.sh

# Run this script to start solr as an entrypoint to configure the container to run as an executable
ENTRYPOINT ["/usr/bin/solr_init.sh"]


