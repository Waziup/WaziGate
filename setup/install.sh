#!/bin/bash
# Installing the WaziGate framework on your device

SCRIPT_PATH=$(dirname $(realpath $0))

sudo apt-get update
sudo apt-get install -y git network-manager python python-pip dnsmasq hostapd

sudo curl -fsSL get.docker.com -o get-docker.sh && sudo sh get-docker.sh
sudo gpasswd -a pi docker
sudo rm get-docker.sh

sudo pip install flask psutil

git clone https://github.com/Waziup/waziup-gateway.git waziup-gateway
cd waziup-gateway
sudo cp setup/docker-compose /usr/bin/ && sudo chmod +x /usr/bin/docker-compose
sudo mkdir -p wazigate-ui/conf; sudo chown $USER -R wazigate-ui/conf
sudo sed -i -e '$i \cd '"$PWD"'; sudo bash ./start.sh &\n' /etc/rc.local

sudo systemctl stop dnsmasq; sudo systemctl stop hostapd

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo bash -c "echo -e 'interface=wlan1\n  dhcp-range=192.168.200.2,192.168.200.200,255.255.255.0,24h\n' > /etc/dnsmasq.conf"
sudo cp setup/hostapd.conf /etc/hostapd/hostapd.conf
sudo sed -i -e '$i \DAEMON_CONF="/etc/hostapd/hostapd.conf"\n' /etc/default/hostapd

sudo cp setup/interfaces /etc/network/interfaces

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo systemctl start dnsmasq

sudo sed -i -e '$i \net.ipv4.ip_forward=1\n' /etc/sysctl.conf
sudo iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE
sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"

#echo -e "loragateway\nloragateway" | sudo passwd $USER

sudo mkdir -p wazigate-edge/conf;
sudo cp setup/clouds.json wazigate-edge/conf/
sudo chown $USER -R wazigate-ui/conf


for i in {10..01}; do
	echo -ne "Rebooting in $i seconds... \033[0K\r"
	sleep 1
done
sudo reboot

exit 0;
