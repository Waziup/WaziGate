#!/bin/bash
# This script is only used by developer to test the production version of the wazigate framework before every release
# Please do not use it if you do not know what you are doing

WAZIUP_VERSION="V1.1-Beta1"

#Setup WAZIUP_ROOT as first argument, with a default value
WAZIUP_ROOT=${1:-$HOME/waziup-gateway}

#--------------------------------#

echo "Changing the password: "
echo -e "loragateway\nloragateway" | sudo passwd $USER
echo "Done."

#--------------------------------#

#Packages
sudo apt-get update
sudo apt-get install -y git

#--------------------------------#

#Downloading wazigate stuff
#Using HTTP makes us to clone without needing persmission via ssh-keys
git clone https://github.com/Waziup/waziup-gateway.git waziup-gateway
cd waziup-gateway

sudo chmod a+x setup/install.sh
sudo chmod a+x setup/uninstall.sh

#--------------------------------#

sudo sed -i "s/^WAZIUP_VERSION=.*/WAZIUP_VERSION=$WAZIUP_VERSION/g" .env

#--------------------------------#

bash ./setup/install.sh

#--------------------------------#

sudo sed -i 's/^DEVMODE.*/DEVMODE=0/g' start.sh

#--------------------------------#

echo "Downloading the docker images..."
cd $WAZIUP_ROOT
sudo docker network create wazigate
sudo docker-compose pull
echo "Done"

for i in {10..01}; do
	echo -ne "Rebooting in $i seconds... \033[0K\r"
	sleep 1
done
sudo reboot

exit 0
