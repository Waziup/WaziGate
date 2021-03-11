#!/bin/bash

printf "Terminating WPA..."

sudo wpa_cli terminate -i wlan0

sleep 1
sudo wpa_cli terminate 2>/dev/null

sleep 1
sudo wpa_cli terminate 2>/dev/null

echo "Done"

printf "Enabling hostpad and dnsmasq..."
sudo systemctl unmask hostapd.service
sudo systemctl enable hostapd.service 2>/dev/null

sudo systemctl stop dnsmasq
sudo systemctl stop hostapd

echo "Done"

printf "Configuring DHCP..."

sudo service networking stop

sleep 1

#Removing prevoious WiFi settings
sudo cp /etc/wpa_supplicant/wpa_supplicant.conf.orig /etc/wpa_supplicant/wpa_supplicant.conf


#sudo cp setup/interfaces_ap /etc/network/interfaces
#sudo rm /var/lib/dhcp/*
sudo sh -c 'echo "interface wlan0" >> /etc/dhcpcd.conf'
sudo sh -c 'echo "static ip_address=192.168.200.1/24" >> /etc/dhcpcd.conf'
sudo sh -c 'echo "static routers=192.168.200.1" >> /etc/dhcpcd.conf'
sudo sh -c 'echo "static domain_name_servers=192.168.200.1 8.8.8.8 fd51:42f8:caae:d92e::1" >> /etc/dhcpcd.conf'

echo "Done"

printf "Starting Networking service..."

sudo service networking start

echo "Done"

#sudo service dnsmasq start; ';
#sudo service hostapd start; ';
#sudo service networking start; ';
#sudo reboot; ';

#	sudo systemctl restart networking

sleep 1
# Killing the WPA Just to be sure it is terminated
ps ax | grep "supplicant" | awk '{print $1}' | sudo xargs kill 2>/dev/null


printf "Configuring packet forwarding..."
sleep 1

sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

echo "Done"

sleep 1

printf "Starting hostpad and dnsmasq..."

sudo systemctl unmask hostapd
sudo systemctl enable hostapd 2>/dev/null
sudo systemctl start hostapd
sudo systemctl start dnsmasq

sleep 1


sudo service dnsmasq start
sudo service hostapd start

echo "Done"

printf "Restarting Networking and DHCP..."

sudo service networking reload

sudo service dhcpcd restart

echo "Done"

sleep 1

#sudo systemctl restart networking
#sudo ip link set eth0 down

# Resolving the issue of not having internet within the containers
# sudo bash -c "echo -e 'nameserver 8.8.8.8' > /etc/resolv.conf"

exit 0;