#!/bin/bash
# This script is only used by developer to test the production version of the wazigate framework before every release
# Please do not use it if you do not know what you are doing

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
git clone https://github.com/Waziup/WaziGate.git waziup-gateway
cd waziup-gateway

mkdir -p apps
cd apps
mkdir -p waziup
cd waziup
rm -rf wazigate-system

git clone https://github.com/Waziup/wazigate-system.git
cd wazigate-system
rm -rf api docs ui Dockerfile conf.json wazigate-system Dockerfile-dev go.* *.go package-lock.json

cd $WAZIUP_ROOT

sudo chmod a+x setup/install.sh
sudo chmod a+x setup/uninstall.sh

#--------------------------------#

bash ./setup/install.sh

#--------------------------------#

sudo sed -i 's/^DEVMODE.*/DEVMODE=0/g' start.sh

#--------------------------------#

#echo "Downloading the docker images..."
# cd $WAZIUP_ROOT
# sudo docker-compose pull
# echo "Done"

for i in {10..01}; do
	echo -ne "Rebooting in $i seconds... \033[0K\r"
	sleep 1
done
sudo reboot

exit 0
