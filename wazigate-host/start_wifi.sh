#!/bin/bash

sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

sleep 1
sudo systemctl disable hostapd.service

sudo service networking stop
sleep 1
sudo sed -i '/^interface wlan0/d' /etc/dhcpcd.conf
sudo sed -i '/^static ip_address=192.168.200.1\/24/d' /etc/dhcpcd.conf
sudo sed -i '/^static routers=192.168.200.1/d' /etc/dhcpcd.conf
sudo sed -i '/^static domain_name_servers=192.168.200.1.*/d' /etc/dhcpcd.conf
# sudo sh -c 'echo "static domain_name_servers=8.8.8.8" >> /etc/dhcpcd.conf'
#sudo mv /etc/network/interfaces /etc/network/interfaces_old;'
#sudo rm /etc/network/interfaces
sudo service networking start

sleep 1

sudo wpa_cli -i wlan0 reconfigure

sleep 1
sudo ip link set dev wlan0 down

sleep 1
sudo wpa_cli terminate

sleep 2
sudo ip link set dev wlan0 up


sleep 1
sudo systemctl restart dhcpcd.service

sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf

sleep 1

sudo systemctl restart networking

# Resolving the issue of not having internet within the containers
# sudo bash -c "echo -e 'nameserver 8.8.8.8' > /etc/resolv.conf"

# sudo sh -c 'echo "static domain_name_servers=8.8.8.8" >> /etc/dhcpcd.conf'

exit 0;
