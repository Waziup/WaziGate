#!/bin/sh
# This file initiates the mongo db

/etc/init.d/mongodb stop
rm -f /var/lib/mongodb/mongod.lock
mongod --repair --dbpath=/var/lib/mongodb/
exec mongod --dbpath=/var/lib/mongodb/