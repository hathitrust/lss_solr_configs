# lss_solr_configs
Configuration files for HT full-text search (ls) Solr

# WARNING!  Work in progress do not use until this notice is removed!


## Files

* **1000common.txt**
* **solrconfig.xml**
* files symlinked to schema.xml
  * **schema6_BM25_wiDVmondo.xml**
  * **schema6_tfidf_wiDVmondo.xml**



## What is the problem we are trying to solve

These files customize Solr for HT full-text search for Solr 6. Our very large indexes require significant changes to Solr defaults in order to work.  We also have custom indexing to deal with multiple languages, and very large documents.

## Explanation of files

The two critical files for configuring Solr are solrconfig.xml and schema.xml
We use two different versions of schema.xml to enable two different relevance ranking algorithms

1. **schema6_tfidf_wiDVmondo.xml** Enables the Solr 4 default tf-idf algorithm.
   Currently this schema is use in the core-Nx cores i.e. core-1x
2. **schema6_BM25_wiDVmondo.xml** Enables the BM25 algorithm with special settings for the OCR field.
   Currently this schema is used in the core-Ny cores i.e. core-1y

All instances use the same **solrconfig.xml** file except for the lss-reindexing Solrs.  (See re-indexing configuration https://tools.lib.umich.edu/confluence/display/HAT/Solr+configuration+for+re-indexing?src=contextnavpagetreemode )


**1000common.txt** is the list of common words used during indexing to create commongrams.  See https://www.hathitrust.org/blogs/large-scale-search/slow-queries-and-common-words-part-2 for background.



See *Background details* (below) for more details

## Deployment and Use

### Re-Indexing

Notes about customizing solrconfig.xml go here
### Testing
### Deployment to Production
### Production Indexing
### Production Serving


## Migrating to later versions of Solr/Lucene
This may need a separate document on confluence.  Think about it...

## Background details

## Considerations for future modification

### Move to AWS


### Testing


## Links to more background
