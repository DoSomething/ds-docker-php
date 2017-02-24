#!/bin/bash
# start db

set -e
set -x

# first, if the /var/lib/mysql directory is empty, unpack it from our predefined db
[ "$(ls -A /var/lib/mysql)" ] && echo "Running with existing database in /var/lib/mysql" || ( echo 'Populate initial db'; tar xpzvf default_mysql.tar.gz )

sudo service mysql start
/usr/bin/mongod --config /etc/mongod.conf --fork --logpath /var/log/mongod.log
