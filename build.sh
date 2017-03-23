#!/bin/bash

source settings.sh

cd $DIR

## Prepare MediaWiki
echo "Setting up MediaWiki and extensions..."

# Clone mediawiki-core
git clone https://gerrit.wikimedia.org/r/mediawiki/core mediawiki
cd mediawiki
composer install --no-dev

# Clone skins
git clone https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git skins/Vector

# Clone extensions
git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/Elastica extensions/Elastica
git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/CirrusSearch extensions/CirrusSearch

cd extensions/Elastica
composer install --no-dev
git checkout -b REL1_28 origin/REL1_28 # latest stable release (ESv2)
cd $DIR/mediawiki

cd extensions/CirrusSearch
git checkout -b REL1_28 origin/REL1_28 # latest stable release (ESv2)
composer install --no-dev
cd $DIR/mediawiki

# Checkout Citolytics
git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch refs/changes/26/329626/8 && git checkout FETCH_HEAD

## Prepare Data
cd $DIR
mkdir $DIR/data
cd $DIR/data

echo "Preparing data... This can take a while..."

# XML Dump
wget https://dumps.wikimedia.org/simplewiki/20170101/simplewiki-20170101-pages-articles.xml.bz2
bzip2 -d simplewiki-20170101-pages-articles.xml.bz2
php $DIR/mediawiki/maintenance/importDump.php --conf $DIR/mediawiki/LocalSettings.php $DIR/data/simplewiki-20170101-pages-articles.xml


# Cirrus
wget $CIRRUS_DUMP_URL
curl -XPOST localhost:9200/mediawiki_content_first/page/_bulk?pretty --data-binary @$DIR/data/simplewiki-20170102-cirrussearch-content.10k.json

# Citolytics dump
wget $CITOLYTICS_DUMP_URL
curl -XPOST localhost:9200/mediawiki_content_first/page/_bulk?pretty --data-binary @$DIR/data/simplewiki_wikisim_elastic.json


