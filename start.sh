#!/bin/bash
# This file initiates the wazigate preparation


# Please add the follwing command at the end of /etc/rc.local file right before exit 0;
#
# cd /home/pi/wazigate/; sudo bash ./start.sh &


# Uncomment these to have the logs
# exec 1>./wazigate-start.log 2>&1		# send stdout and stderr to a log file
# set -x                         		# tell sh to display commands before execution

DEVMODE=0

SCRIPT_PATH=$(dirname $(realpath $0))

#------------#

#We need this because when you remove the cable it does not work
sudo ip link set eth0 down
sleep 1
sudo ip link set eth0 up

#------------#

# Resolving the issue of not having internet within the containers
sudo bash -c "echo -e 'nameserver 8.8.8.8' > /etc/resolv.conf"

#------------#

#check if the server is accessible
acc=$(curl -Is https://waziup.io | head -n 1 | awk '{print $2}')
if [ "$acc" != "200" ]; then
	echo "[ Warning ]: Waziup.io is not accessible!"
fi

#------------#

cd $SCRIPT_PATH

#Launch the wazigate-host service
sudo bash ./wazigate-host/start.sh &
sleep 1

#------------#

#Setting the default SSID for AP using Rapi MAC address
if [ ! -f .default_ap_done ] ; then

	MAC="XXXXX"

	if [ -f  /sys/class/net/eth0/address ] ; then
		MAC=$(cat /sys/class/net/eth0/address)
	else
		if [ -f  /sys/class/net/wlan0/address ] ; then
			MAC=$(cat /sys/class/net/wlan0/address)
		fi;
	fi;
	
	MAC=${MAC//:}
	gwId="${MAC^^}"
	sudo sed -i "s/^ssid.*/ssid=WAZIGATE_$gwId/g" /etc/hostapd/hostapd.conf

	touch .default_ap_done
	
	#Launch the HotSpot Mode
	sudo bash wazigate-host/start_hotspot.sh
fi;

sleep 2

#------------#

#We might remove this from here and keep it in the setup script
if [ ! -f $SCRIPT_PATH/wazigate-system/conf/conf.json ]; then
	mkdir -p $SCRIPT_PATH/wazigate-system/conf/
	cp $SCRIPT_PATH/setup/conf.default.json $SCRIPT_PATH/wazigate-system/conf/conf.json
fi

#------------#

# Resolving the issue of not having internet within the containers
sudo bash -c "echo -e 'nameserver 8.8.8.8' > /etc/resolv.conf"

#Starting the docker containers
if [ $DEVMODE == 1 ]; then
	echo "[ Notice ]: Running in developer mode"
	sudo docker-compose -f docker-compose.yml -f docker-compose-dev.yml up -d
else
	sudo docker-compose up -d
fi

#removing dangling images
#sudo docker image prune -f

#------------#


exit 0;
