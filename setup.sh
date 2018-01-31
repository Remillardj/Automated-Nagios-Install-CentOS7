#!/bin/bash

# Make sure to sure as sudo
if [[ $EUID -ne 0]]; then
  echo "This script must be ran as sudo"
  exit 1
fi

# check for updates
yum update
yum update -y

# Begin installation
NAGIOS_VERSION = "4.1.1"
NAGIOS_PLUGINS = "2.0.3"
NAGIOS_HOME = "/usr/local/nagios"
NAGIOS_WEB_ADMIN_USER = "admin"
NAGIOS_DOWNLOAD_PATH = "/tmp/downloads/"
NAGIOS_DOWNLOAD_LINK = "http://nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz"

# check if it doesn't exist, then create one
# I'm not worried that it is a symlink
if [ ! -d "$NAGIOS_DOWNLOAD_PATH" ]; then
  mkdir $NAGIOS_DOWNLOAD_PATH
fi

if [ ! -d "~/yum/" ]; then
  mkdir "~/yum/"
fi

cd ~/yum/

# Install tools needed for Nagios

# Install Apache2
yum install httpd mod_ssl
# Install Apache2 utils
yum install httpd-tools -y
# install unzip
yum install zip
yum install unzip
# Install php
yum install php php-mysql php-devel php-gd php-pecl-memcache php-pspell php-snmp php-xmlrpc php-xml
# Install Development tools
yum groupinstall 'Development Tools'
yum install gcc gcc-c++ make openssl-devel #backup for devtools
# Install libgd
yum install gd gd-devel
yum install libgd2
# Install OpenSSL
yum install libtool perl-core zlib-devel -y
yum install openssl
# Install Libssl
yum install openssl.i386 openssl-devel.x86_64
yum install openssl-devel

# Start apache2
/usr/sbin/apachectl start

# Create users
useradd nagios
groupadd nagioscommand

# Move to download paths
cd $NAGIOS_DOWNLOAD_PATH
if ! [-e $NAGIOS_DOWNLOAD_LINK ]; then
  wget $NAGIOS_DOWNLOAD_LINK
fi

tar xzf $NAGIOS_DOWNLOAD_LINK
./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make
make install

# Make Nagios start on boot
ln -s /etc/init.d/nagios /etc/rcS.d/S99nagios

# Reconfigure Apache
# Start apache
systemctl start http
# check status of apache
systemctl status http

httpd -M
systemctl restart httpd
# https://www.digitalocean.com/community/tutorials/how-to-set-up-mod_rewrite-for-apache-on-centos-7

# Start nagios
service nagios start

# Ask user to delete installation files or not
while true; do
  read -p "Delete installation files?" yn
  case $yn in
    [Yy]* ) rm -rf /tmp/downloads/*; break;;
    [Nn]* ) exit;;
    * ) echo "Please type in Y/y or N/n.";;
  esac
done
