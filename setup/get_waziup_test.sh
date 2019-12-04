#!/bin/bash
# This script is only used by developer to test the production version of the wazigate framework before every release
# Please do not use it if you do not know what you are doing

WAZIUP_VERSION="V1.0-beta4"

#Setup WAZIUP_ROOT as first argument, with a default value
WAZIUP_ROOT=${1:-$HOME/waziup-gateway}
#--------------------------------#

#Packages
sudo apt-get update
sudo apt-get install -y git

#--------------------------------#

#Downloading wazigate stuff
#Using HTTP makes us to clone without needing persmission via ssh-keys
git clone https://github.com/Waziup/waziup-gateway.git waziup-gateway
cd waziup-gateway

chmod a+x setup/install.sh
chmod a+x setup/uninstall.sh

#--------------------------------#

sed -i "s/^WAZIUP_VERSION=.*/WAZIUP_VERSION=$WAZIUP_VERSION/g" .env

#--------------------------------#

sudo bash ./setup/install.sh

#--------------------------------#

sed -i 's/^DEVMODE.*/DEVMODE=0/g' start.sh

#--------------------------------#

echo "Downloading the docker images..."
cd $WAZIUP_ROOT
docker-compose pull
echo "Done"

for i in {10..01}; do
	echo -ne "Rebooting in $i seconds... \033[0K\r"
	sleep 1
done
sudo reboot

exit 0
