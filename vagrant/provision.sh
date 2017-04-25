#!/usr/bin/env bash

# Load settings
source /vargrant/settings.sh

# See https://github.com/smebberson/vagrant-simple-nginx-php


sudo apt-get update
sudo apt-get install -y git curl vim

# mysql
if [ ! -e /etc/vagrant/mysql ]
then
	echo ">>> setting up mysql"
  sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
  sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

  sudo apt-get install -y mysql-server php5-mysql
  sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf
  mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES; SET GLOBAL max_connect_errors=10000;"
  mysql -u root -proot -e "GRANT ALL ON mediawiki.* to 'mediawiki' identified by 'mediawiki';"

  sudo /etc/init.d/mysql restart

  # only run once
  touch /etc/vagrant/mysql

else
	echo ">>> mysql already setup..."
fi


# nginx
if [ ! -e /etc/vagrant/nginx ]
then
	echo ">>> setting up nginx"

  sudo apt-get install -y nginx

  # update the default vhost
  sudo cat /vagrant/nginx-site.conf | sudo tee /etc/nginx/sites-available/default > /dev/null
  sudo service nginx restart

  # only run once
  touch /etc/vagrant/nginx

else
	echo ">>> mysql already setup..."
fi


# php
if [ ! -e /etc/vagrant/php ]
then
	echo ">>> setting up php"

  sudo apt-get install -y php5-cli php5-fpm
  # php-xml php-mbstring  php-curl
  sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
  sudo /etc/init.d/php5-fpm restart
  # only run once
	touch /etc/vagrant/php
else
  echo ">>> php already setup..."

fi


if [ ! -e /etc/vagrant/composer ]
then
	echo ">>> setting up composer"

  # Composer
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
  sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer

  php -r "unlink('composer-setup.php');"

  # only run once
  touch /etc/vagrant/composer

else
	echo ">>> composer already setup..."
fi





# Elasticsearch

if [ ! -e /etc/vagrant/elasticsearch ]
then
	echo ">>> setting up elsaticsearch"

  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  sudo apt-get install -y apt-transport-https
  echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-5.x.list
  sudo apt-get update
  sudo apt-get install -y elasticsearch

  # only run once
  touch /etc/vagrant/elasticsearch

else
	echo ">>> elasticsearch already setup..."
fi


# MediaWiki

#git clone https://gerrit.wikimedia.org/r/mediawiki/core /vagrant/mediawiki
git clone https://github.com/wikimedia/mediawiki.git /vagrant/mediawiki

#git clone https://gerrit.wikimedia.org/r/p/mediawiki/skins/Vector.git /vagrant/mediawiki/skins/Vector
git clone https://github.com/wikimedia/mediawiki-skins-Vector.git /vagrant/mediawiki/skins/Vector

#git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/Elastica /vagrant/mediawiki/extensions/Elastica
git clone https://github.com/wikimedia/mediawiki-extensions-Elastica.git /vagrant/media/extensions/Elastica

git clone https://gerrit.wikimedia.org/r/p/mediawiki/extensions/CirrusSearch /vagrant/mediawiki/extensions/CirrusSearch

# Install dependecies
# composer install --no-dev
cd /vagrant/mediawiki && composer install --no-dev
cd /vagrant/mediawiki/extensions/Elastica && composer install --no-dev

cd /vagrant/mediawiki/extensions/CirrusSearch && composer install --no-dev


cd /vagrant/mediawiki/extensions/CirrusSearch && git fetch https://gerrit.wikimedia.org/r/mediawiki/extensions/CirrusSearch refs/changes/26/329626/8 && git checkout FETCH_HEAD

cat /vagrant/mediawiki-settings.php >> /vagrant/mediawiki/LocalSettings.php

# Prepare Cirrussearch
#php /vagrant/mediawiki/extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php
#php /vagrant/mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipLinks --indexOnSkip
#php /vagrant/mediawiki/extensions/CirrusSearch/maintenance/forceSearchIndex.php --skipParse


# Download data
