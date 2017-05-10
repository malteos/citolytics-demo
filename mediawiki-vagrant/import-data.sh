#!/usr/bin/env bash

export PAGE_SQL_URL=https://dumps.wikimedia.org/simplewiki/20170101/simplewiki-20170101-page.sql.gz
#export CIRRUS_DUMP_URL=https://dumps.wikimedia.org/other/cirrussearch/20170424/simplewiki-20170424-cirrussearch-content.json.gz
export CIRRUS_DUMP_URL=http://citolytics-demo.wmflabs.org/dumps/cirrus.json.gz
export CIRRUS_INDEX=wiki_content_first
export CITOLYTICS_DUMP_URL=http://citolytics-demo.wmflabs.org/dumps/citolytics_simplewiki.json.gz

cd /vagrant/tmp

# Pages
wget $PAGE_SQL_URL -O page.sql.gz
gzip -d page.sql.gz
mysql -u wikiadmin -pwikipassword wiki < page.sql

# Cirrus
wget $CIRRUS_DUMP_URL -O cirrus.json.gz
gzip -d cirrus.json.gz

mkdir cirrus.splits.d
split -l 10000 cirrus.json cirrus.splits.d/
for f in cirrus.splits.d/{.,}*; do curl -XPOST localhost:9200/$CIRRUS_INDEX/page/_bulk?pretty --data-binary @$f; sleep 1s; done

# Citolytics
wget $CITOLYTICS_DUMP_URL -O citolytics.json.gz
gzip -d citolytics.json.gz
mkdir citolytics.splits.d
split -l 10000 citolytics.json citolytics.splits.d/
for f in citolytics.splits.d/{.,}*; do curl -XPOST localhost:9200/$CIRRUS_INDEX/page/_bulk?pretty --data-binary @$f; sleep 1s; done

# Clean up
rm -R citolytics.splits.d
rm -R cirrus.splits.d
rm cirrus.json
rm citolytics.json
rm page.sql
