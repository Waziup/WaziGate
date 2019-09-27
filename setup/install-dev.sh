#!/bin/bash
# Installing the WaziGate framework on your device for development
# @author: Mojiz 21 Jun 2019

WAZIUP_DIR=$HOME/dev/waziup-gateway

#invoking main install script
$WAZIUP_DIR/setup/install.sh

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

#installing wazigate
#Using HTTP makes us to clone without needing persmission via ssh-keys
git clone --recursive https://github.com/Waziup/waziup-gateway.git waziup-gateway-dev
cd waziup-gateway-dev

sed -i 's/^DEVMODE.*/DEVMODE=1/g' start.sh
sudo chmod +x start.sh
sudo chmod +x stop.sh

sudo docker-compose -f docker-compose.yml -f docker-compose-dev.yml build --force-rm

exit 0;
