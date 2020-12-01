#!/bin/bash
# This file initiates the mongo db

/etc/init.d/mongodb stop
rm -f /var/lib/mongodb/mongod.lock
mongod --repair --dbpath=/var/lib/mongodb/
mongod --dbpath=/var/lib/mongodb/