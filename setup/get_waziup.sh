#!/bin/bash
# This script downloads and installs the Wazigate 

WAZIUP_VERSION="V1.0-beta2"

echo "Downloading Wazigate..."
sudo curl -fsSLO https://github.com/Waziup/waziup-gateway/archive/$WAZIUP_VERSION.tar.gz
tar -xzvf $WAZIUP_VERSION.tar.gz
mv waziup-gateway-1.0-beta1 waziup-gateway
cd waziup-gateway
chmod a+x setup/install.sh
chmod a+x setup/uninstall.sh
./setup/install.sh
