#!/bin/bash

echo "Enter the Username: "
read user

echo "Enter the users email address: "
read email

# Directories
mkdir /var/www
chown $user:$user /var/www

# Repositories
echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | tee /etc/apt/sources.list.d/virtualbox.list

# Keys
wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 94558F59
gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
gpg -a --export CD2EFD2A | sudo apt-key add -

# Update
apt-get update
apt-get dist-upgrade -y
apt-get autoremove

# Install
apt-get install -y python-software-properties software-properties-common mysql-server
apt-get install -y make gcc postfix unrar git-core git-flow bash-completion subversion git iotop mytop nginx-full memcached
apt-get install -y php5-fpm php5-cli php5-suhosin php5-xsl php5-gd php5-curl php5-xmlrpc php5-imagick imagemagick
apt-get install -y php5-xcache php5-mysqlnd php-pear php5-mcrypt php5-mhash libmcrypt-dev mcrypt php5-dev php5-memcache php5-xdebug
apt-get install -y unrar aptitude virtualbox-4.2
apt-get install -y iotop mytop dnsmasq redis-server

# Configuration
cp nginx/nginx.conf /etc/nginx/nginx.conf
cp nginx/development.conf /etc/nginx/sites-available/development.conf
cp nginx/tools.conf /etc/nginx/sites-available/tools.conf
cp php5/demo.conf /etc/php5/pool.d/user.conf
cp mysql/user.cnf /etc/mysql/conf.d/user.cnf
cp postfix/main.cf /etc/postfix/main.cf
cp postfix/recipient_canonical_map /etc/postfix/recipient_canonical_map

rm /etc/php5/fpm/pool.d/www.conf
rm /etc/nginx/sites-enabled/*

ln -sf /etc/nginx/sites-available/development.conf /etc/nginx/sites-enabled/development.conf
ln -sf /etc/nginx/sites-available/tools.conf /etc/nginx/sites-enabled/tools.conf

# Replace variables
perl -pi -w -e "s/USERNAME/$user/g;" /etc/php5/fpm/pool.d/user.conf
perl -pi -w -e "s/USERNAME/$user/g;" /etc/nginx/nginx.conf
perl -pi -w -e "s/EMAIL/$email/g;" /etc/postfix/recipient_canonical_map

# DNSmasq
echo 'address=/dev/127.0.0.1' > /etc/dnsmasq.d/dev
echo 'listen-address=127.0.0.1' >> /etc/dnsmasq.d/dev
echo 'address=/tools/127.0.0.1' > /etc/dnsmasq.d/tools
echo 'listen-address=127.0.0.1' >> /etc/dnsmasq.d/tools

# Restart services
service postfix restart
service nginx restart
service php5-restart
service mysql restart
service dnsmasq restart

# Add user to virtualbox
usermod -a -G vboxusers $user
