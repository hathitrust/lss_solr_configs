FROM solr:8.11.2

#This docker works
#COPY --chown=solr:solr . /var/solr/data

#All cores sharing solr.xml
COPY --chown=solr:solr ./solr/solr.xml /var/solr/data

#Create core-x
COPY --chown=solr:solr ./solr/conf /var/solr/data/core-x/conf/
COPY --chown=solr:solr ./solr/lib /var/solr/data/core-x/lib/
COPY --chown=solr:solr solr/core-x.properties /var/solr/data/core-x/core.properties
COPY --chown=solr:solr ./solr/data /var/solr/data/core-x/data

#Create core-y
COPY --chown=solr:solr ./solr/conf /var/solr/data/core-y/conf/
COPY --chown=solr:solr ./solr/lib /var/solr/data/core-y/lib/
COPY --chown=solr:solr solr/core-y.properties /var/solr/data/core-y/core.properties
COPY --chown=solr:solr ./solr/data /var/solr/data/core-y/data/
