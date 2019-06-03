#!/bin/bash

#By Moji
#This file updates the local copy of waziup.io

cd /var/www/html/
wget -O wazidocs.zip https://github.com/Waziup/waziup.io/archive/master.zip
rm -r waziup.io
unzip wazidocs.zip
rm wazidocs.zip
mv waziup.io-master waziup.io
cd waziup.io
hugo -b /waziup.io/public/
