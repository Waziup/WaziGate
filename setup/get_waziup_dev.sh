#!/bin/bash
# Installing the WaziGate framework on your device for development
# @author: Mojiz 21 Jun 2019

read -p "This script will download and install the development version of the Wazigate. Continue (y/n)? "
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Existing."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

sudo apt-get update
sudo apt-get install -y git

#installing wazigate
#Using HTTP makes us to clone without needing persmission via ssh-keys
git clone --recursive https://github.com/Waziup/waziup-gateway.git waziup-gateway
cd waziup-gateway

sed -i 's/^DEVMODE.*/DEVMODE=1/g' start.sh
sudo chmod +x start.sh
sudo chmod +x stop.sh

#-----------------------#
# Adding FTP
sudo apt-get install -y git pure-ftpd
sudo groupadd ftpgroup
sudo usermod -a -G ftpgroup $USER
sudo chown -R $USER:ftpgroup "$PWD"
sudo pure-pw useradd upload -u $USER -g ftpgroup -d "$PWD" -m <<EOF
loragateway
loragateway
EOF
sudo pure-pw mkdb
sudo service pure-ftpd restart

echo "Installation finished. Use 'setup/install.sh' to install and configure your Wazigate. Use 'docker-compose build' to build the containers."

exit 0;
