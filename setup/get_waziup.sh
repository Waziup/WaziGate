#!/bin/bash
# This script downloads and installs the Wazigate 

WAZIUP_VERSION="V1.0-beta2.1"

#--------------------------------#

echo "Downloading Wazigate..."
sudo curl -fsSLO https://github.com/Waziup/waziup-gateway/archive/$WAZIUP_VERSION.tar.gz
tar -xzvf $WAZIUP_VERSION.tar.gz
mv waziup-gateway-1.0-beta2 waziup-gateway
cd waziup-gateway
chmod a+x setup/install.sh
chmod a+x setup/uninstall.sh

#--------------------------------#

./setup/install.sh

#--------------------------------#

sed -i 's/^DEVMODE.*/DEVMODE=0/g' start.sh

#--------------------------------#

echo "Downloading the docker images..."
cd $WAZIUP_ROOT/
docker-compose pull
echo "Done"

for i in {10..01}; do
	echo -ne "Rebooting in $i seconds... \033[0K\r"
	sleep 1
done
sudo reboot

exit 0
