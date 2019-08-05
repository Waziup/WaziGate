#!/bin/bash
# Installing the WaziGate framework on your device for development
# @author: Mojiz 21 Jun 2019

#Uninstall wazigate if already installed before:
if [ -d "waziup-gateway" ]; then
	echo "Uninstalling..."
	
	
	echo "Removing the containers..."
	cd waziup-gateway
	sudo docker-compose stop
	sudo docker system prune -fa
	sudo docker rm $(docker ps -a -q)
	sudo docker rmi -f $(docker images -a -q)
	cd ..
	echo "Done"

	echo "Renaming the old directory..."
	newName="waziup-gateway_OLD_$((RANDOM % 100000))"
	mv waziup-gateway "$newName"
	echo "Done"
	
	
	echo "Unsetting the configs..."
	sudo sed -i 's/^.*waziup-gateway.*//g' /etc/rc.local
	sudo sed -i 's/^.*DAEMON_CONF=.*//g' /etc/default/hostapd
	sudo sed -i 's/^net.ipv4.ip_forward=.*//g' /etc/sysctl.conf
	echo "Done"
	
	echo -e "\n\tUninstalling finished.\n"
fi

sudo apt-get update
sudo apt-get install -y git network-manager python3 python3-pip dnsmasq hostapd connectd pure-ftpd i2c-tools libopenjp2-7 libtiff5

sudo -H pip3 install flask psutil luma.oled

#-----------------------#

sudo groupadd ftpgroup
sudo usermod -a -G ftpgroup $USER
sudo chown -R $USER:ftpgroup "$PWD"

sudo pure-pw useradd upload -u $USER -g ftpgroup -d "$PWD" -m <<EOF
loragateway
loragateway
EOF
sudo pure-pw mkdb

sudo service pure-ftpd restart

#------------------------#

#Setup I2C
echo -e '\n\ndtparam=i2c_arm=on' | sudo tee -a /boot/config.txt
sudo bash -c "echo -n ' bcm2708.vc_i2c_override=1' >> /boot/cmdline.txt"
echo -e '\ni2c-bcm2708\ni2c-dev' | sudo tee -a /etc/modules-load.d/raspberrypi.conf

#REF: http://www.runeaudio.com/forum/how-to-enable-i2c-t1287.html

#------------------------#

#installing docker
sudo curl -fsSL get.docker.com -o get-docker.sh && sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo rm get-docker.sh

#------------------------#

#installing wazigate
#Using HTTP makes us to clone without needing persmission via ssh-keys
git clone --recursive https://github.com/Waziup/waziup-gateway.git waziup-gateway
cd waziup-gateway
sudo cp setup/docker-compose /usr/bin/ && sudo chmod +x /usr/bin/docker-compose
sudo mkdir -p wazigate-ui/conf
sudo chown $USER -R wazigate-ui/conf
sudo sed -i -e '$i \cd '"$PWD"'; sudo bash ./start.sh &\n' /etc/rc.local

#------------------------#

#Setting up the Access Point
#sudo systemctl stop dnsmasq; sudo systemctl stop hostapd

#sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
#sudo bash -c "echo -e 'interface=wlan1\n  dhcp-range=192.168.200.2,192.168.200.200,255.255.255.0,24h\n' > /etc/dnsmasq.conf"
#sudo cp setup/hostapd.conf /etc/hostapd/hostapd.conf
#sudo sed -i -e '$i \DAEMON_CONF="/etc/hostapd/hostapd.conf"\n' /etc/default/hostapd

sudo cp setup/interfaces_ap /etc/network/interfaces

#sudo systemctl unmask hostapd
#sudo systemctl enable hostapd
#sudo systemctl start hostapd
#sudo systemctl start dnsmasq

#sudo sed -i -e '$i \net.ipv4.ip_forward=1\n' /etc/sysctl.conf
#sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
#sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

#echo -e "loragateway\nloragateway" | sudo passwd $USER

#Configuring the Edge
sudo mkdir -p wazigate-edge/conf
sudo cp setup/clouds.json wazigate-edge/conf/
sudo chown $USER -R wazigate-edge/conf

#Remote.it Credentials
if [ "$REMOTE" != "" ]; then
	arrIN=($REMOTE)
	echo -e "email=\"${arrIN[0]}\"\npassword=\"${arrIN[1]}\"" > remote.it/creds
fi

sed -i 's/^DEVMODE.*/DEVMODE=1/g' start.sh
sudo chmod +x start.sh
sudo chmod +x stop.sh

sudo docker-compose -f docker-compose.yml -f docker-compose-dev.yml build --force-rm

for i in {10..01}; do
	echo -ne "Rebooting in $i seconds... \033[0K\r"
	sleep 1
done
sudo reboot

exit 0;