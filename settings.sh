#!/bin/bash

# Adjust this
export DIR=/srv/wikisim/www/mediawiki

export MYSQL_HOST=localhost
export MYSQL_DB=mediawiki
export MYSQL_USER=mediawiki
export MYSQL_PW=mediawiki

# This should stay the same

export ES_HOST=localhost

export SITE_NAME=Wiki
export SITE_URL=http://localhost

# Mediawiki version
export RELEASE=REL1_28

export XML_DUMP_URL=https://dumps.wikimedia.org/simplewiki/20170101/simplewiki-20170101-pages-articles.xml.bz2
export CIRRUS_DUMP_URL=https://dumps.wikimedia.org/other/cirrussearch/20170109/simplewiki-20170109-cirrussearch-content.json.gz

export CITOLYTICS_DUMP_URL=
