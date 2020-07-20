#!/bin/bash
# This script downloads and installs the Wazigate 

WAZIUP_VERSION="V1.0"

#--------------------------------#

echo "Downloading Wazigate..."
sudo curl -fsSLO https://github.com/Waziup/waziup-gateway/archive/$WAZIUP_VERSION.tar.gz
tar -xzvf $WAZIUP_VERSION.tar.gz
mv waziup-gateway* waziup-gateway
cd waziup-gateway
sudo chmod a+x setup/install.sh
sudo chmod a+x setup/uninstall.sh

#--------------------------------#

WAZIGATE_ID=`cat /sys/class/net/eth0/address | tr -d ":"`
sudo sed -i "s/^WAZIUP_VERSION=.*/WAZIUP_VERSION=$WAZIUP_VERSION/g" .env
sudo sed -i "s/^WAZIGATE_ID=.*/WAZIGATE_ID=$WAZIGATE_ID/g" .env

#--------------------------------#

bash ./setup/install.sh

#--------------------------------#

sudo sed -i 's/^DEVMODE.*/DEVMODE=0/g' start.sh

#--------------------------------#

echo "Downloading the docker images..."
cd $WAZIUP_ROOT/
sudo docker-compose pull
echo "Done"

for i in {10..01}; do
	echo -ne "Rebooting in $i seconds... \033[0K\r"
	sleep 1
done
sudo reboot

exit 0
