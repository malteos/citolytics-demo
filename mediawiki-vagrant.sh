#!/usr/bin/env bash

# This will clone into your user home directory.
git clone --recursive https://gerrit.wikimedia.org/r/mediawiki/vagrant

cd vagrant
./setup.sh

vagrant up
vagrant roles enable cirrus pageimages # ....



cd vagrant/mediawiki/extensions/CirrusSearch && git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch refs/changes/26/329626/8 && git checkout FETCH_HEAD

wget https://dumps.wikimedia.org/simplewiki/20170101/simplewiki-20170101-page.sql.gz
# import

wget # cirrussearch
curl

wget # citolytics
curl

cp CitolyticsSettings.php vagrant/mediawiki/settings.d/

#### update android api url to >>
