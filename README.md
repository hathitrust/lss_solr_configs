# lss_solr_configs
Configuration files for HT full-text search (ls) Solr

# WARNING!  Work in progress do not use until this notice is removed!

## Overview

A solr configuration for LSS consists of five symlinks in the same directory
that point to the correct files for that core:

Three of these symlinks will point to the same file regardless of what
core you're configuring:

* `1000common.txt`.  See [background information](https://www.hathitrust.org/blogs/large-scale-search/slow-queries-and-common-words-part-2)
and [how to update the list of words](https://tools.lib.umich.edu/confluence/display/HAT/Tuning+CommonGrams+and+the+cache-warming+queries).
* `schema.xml`, the generic schema file
* `solrconfig.xml`, the generic solr configuration for handlers and config

The other two files are specific to whether it's an x/y core (`similarity.xml`)
and what the core number is `mergePolicy.xml` These are referenced in `schema.xml`
and `solrconfig.xml` via a standard XML `<!ENTITY <name> SYSTEM "./<relative_file_path>">`.
This allows us to have a single base file that can be modified just by
putting a symlink to the right file in the conf directory.


* `similarity.xml` contains directives to use either the tfidf or BM25 similarity
scores and are stored in the corresponding directories. We've
been linking the tfidf file into `core-#x` and the BM25 into `core-#y` for each
of the cores.
* `mergePolicy.xml` configures merge variables and ramBuffer size for each 
  individual core (as [specified in Confluence](https://tools.lib.umich.edu/confluence/display/HAT/Tuning+re-indexing)),
  with a goal of making them different enough that it's 
  less likely that many cores will be involved in big merges at the same time.

  Note that production solrs should symlink in `serve/mergePolicy.xml`, while the 
  indexing servers should use the core-specific version in the 
  `indexing_core_specific` directory.

## What is the problem we are trying to solve

These files customize Solr for HT full-text search for Solr 6. Our very large indexes require significant changes to Solr defaults in order to work.  We also have custom indexing to deal with multiple languages, and very large documents.

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
