# citolytics-demo
Simple guide (and demo script) for building a MediaWiki-Citolytics demo based on Wikipedia's simplewiki.

## Requirements

```
php php-mysql php-curl php-xml php-mbstring composer mysql-server elasticsearch git
```

### Settings

Define settings for your setup.

```
export DIR=/srv/wikisim/www/mediawiki

export MYSQL_HOST=localhost
export MYSQL_DB=mediawiki
export MYSQL_USER=mediawiki
export MYSQL_PW=mediawiki

export ES_HOST=localhost

export SITE_NAME=Wiki
export SITE_URL=http://localhost

# Mediawiki version
export RELEASE=REL1_28

# Path to CirrusSearch dump
export CIRRUS_DUMP_URL=https://dumps.wikimedia.org/other/cirrussearch/20170109/simplewiki-20170109-cirrussearch-content.json.gz

# Path to Citolytics output (generate with Flink job)
export CITOLYTICS_DUMP_URL=
```

### Prepare MediaWiki

Run the following commands to checkout all needed repositories:
```
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

```

### Update MediaWiki settings

Open and install the MediaWiki in your browser. Add the following lines to the end of your LocalSettings.php:
```
# Add this to the end of your LocalSettings.php
require_once( "$IP/extensions/Elastica/Elastica.php" );
require_once( "$IP/extensions/CirrusSearch/CirrusSearch.php" );
$wgCirrusSearchServers = array( 'localhost' );
$wgSearchType = 'CirrusSearch';
$wgCirrusSearchEnableCitolytics = true;
$wgCirrusSearchDevelOptions['ignore_missing_rev'] = true;
```

### Prepare CirrusSearch index

Create ES index for CirrusSearch:

```
php $DIR/mediawiki/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php
php $DIR/mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipLinks --indexOnSkip
php $DIR/mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipParse
```

Download CirrusSearch dump, split the dump in chunks and send the data to Elasticsearch:
```
mkdir $DIR/data
wget $CIRRUS_DUMP_URL -O cirrus.json.gz
zcat cirrus.json.gz > cirrus.json
mkdir $DIR/data/cirrus.splits.d
split -l 1000 $DIR/data/cirrus.json $DIR/data/cirrus.splits.d/
for f in $DIR/data/cirrus.splits.d/{.,}*; do curl -XPOST $ES_HOST:9200/mediawiki_content_first/page/_bulk?pretty --data-binary @$f; done
```

### Popupate Citolytics data to ES

```
wget $CITOLYTICS_DUMP_URL -O citolytics_simplewiki.json
rm -R $DIR/data/citolytics.splits.d
mkdir $DIR/data/citolytics.splits.d
split -l 1000 $DIR/data/citolytics_simplewiki.json $DIR/data/citolytics.splits.d/
for f in $DIR/data/citolytics.splits.d/{.,}*; do curl -XPOST $ES_HOST:9200/mediawiki_content_first/page/_bulk?pretty --data-binary @$f; done

```

Now, you can run the search query `citolytics:"Page title"` to retrieve the Citolytics recommendations for `Page title`.


## Setup via Script
To build the demo simply adjust the settings in `settings.sh` and then run `build.sh`.
```
./build.sh
```
