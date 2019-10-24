#!/bin/bash
# This file initiates the wazigate preparation


# Please add the follwing command at the end of /etc/rc.local file right before exit 0;
#
# cd /home/pi/wazigate/; sudo bash ./start.sh &


# Uncomment these to have the logs
# exec 1>./wazigate-start.log 2>&1		# send stdout and stderr to a log file
# set -x                         		# tell sh to display commands before execution

DEVMODE=1

SCRIPT_PATH=$(dirname $(realpath $0))

#check if the server is accessible
acc=$(curl -Is https://waziup.io | head -n 1 | awk '{print $2}')
if [ "$acc" != "200" ]; then
	echo "[ Warning ]: Waziup.io is not accessible!"
fi

#------------#

cd $SCRIPT_PATH

#Launch the wazigate-host service
sudo bash ./wazigate-host/start.sh &
sleep 2

#------------#

echo -e "STARTING\nWaziGate..." > wazigate-host/oled/msg.txt

#------------#


#IF Access Point Mode Activated
if [ -f /etc/network/interfaces ]; then

	#sudo nodogsplash #Not working when there is no internet connection, so we leave it :/
	
	#Setting the default SSID for AP using Rapi MAC address
	if [ ! -f .default_ap_done ] ; then
	
		MAC="XXXXX"

		if [ -f  /sys/class/net/eth0/address ] ; then
			MAC=$(cat /sys/class/net/eth0/address)
		fi;

		if [ -f  /sys/class/net/wlan0/address ] ; then
			MAC=$(cat /sys/class/net/wlan0/address)
		fi;
		
		MAC=${MAC//:}
		gwId="${MAC^^}"
		sudo sed -i "s/^ssid.*/ssid=WAZIGATE_$gwId/g" /etc/hostapd/hostapd.conf

		touch .default_ap_done
	fi;

	sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
	sudo sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

	sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
	sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
	sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

	#sudo systemctl stop hostapd
	
	sudo systemctl unmask hostapd
	sudo systemctl enable hostapd

	sudo systemctl start dnsmasq
	sudo systemctl start hostapd

fi

sleep 2

#------------#

#We might remove this from here and keep it in the setup script
if [ ! -f $SCRIPT_PATH/wazigate-system/conf/conf.json ]; then
	mkdir -p $SCRIPT_PATH/wazigate-system/conf/
	cp $SCRIPT_PATH/setup/conf.default.json $SCRIPT_PATH/wazigate-system/conf/conf.json
fi

#------------#

# Showing a msg on the OLED display
echo -e "Loading\n Modules..." > wazigate-host/oled/msg.txt

#------------#

#Starting the docker containers
if [ $DEVMODE == 1 ]; then
	echo "[ Notice ]: Running in developer mode"
	sudo docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d
else
	sudo docker-compose up -d
fi

#removing dangling images
#sudo docker image prune -f

rm -f wazigate-host/oled/msg.txt #Clear the OLED screen

sleep 5

#------------#

#sudo /etc/init.d/network-manager restart
#sleep 2

#------------#

#Check if the gateway is registered in remote.it and register it if needed (with 5 minutes timeout)
#sudo timeout 300 bash ./remote.it/setup.sh &

#------------#

exit 0;
