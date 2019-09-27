#!/bin/bash
# This script downloads and installs the Wazigate 

WAZIUP_VERSION="V1.0-beta1"

read -p "This script will download and install Wazigate. Continue (y/n)? "
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Existing."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo "Downloading Wazigate..."
sudo curl -fsSLO https://github.com/Waziup/waziup-gateway/archive/$WAZIUP_VERSION.tar.gz
tar -xzvf $WAZIUP_VERSION.tar.gz
mv waziup-gateway-1.0-beta1 waziup-gateway
cd waziup-gateway
chmod a+x waziup-gateway/install.sh
./setup/install.sh
