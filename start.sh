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

sudo service ntp stop
sudo ntpdate -u pool.ntp.org
sudo service ntp start

#------------#

# In AP mode we need this fix, otherwise RPi kicks the clients out after a while.
if ! grep -qFx "wifi.scan-rand-mac-address=no" /etc/NetworkManager/NetworkManager.conf; then 
	echo -e '\n[device]\nwifi.scan-rand-mac-address=no' | sudo tee -a /etc/NetworkManager/NetworkManager.conf
fi

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
sudo bash ./wazigate-host/start.sh $DEVMODE &
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

	
	# Launch the HotSpot Mode
	sudo bash wazigate-host/start_hotspot.sh
	touch .default_ap_done
	
	
	# Pulling the docker images and launching the required ones
	
	cd $SCRIPT_PATH
	sudo docker-compose pull

	cd $SCRIPT_PATH/apps/waziup/wazigate-system
	sudo docker-compose pull
	sudo docker-compose up -d  --no-build	
	

	# Running the lora App to make the containers created for the first time
	# Since there is an issue with postgres initialization and so Chirpstack won't start, 
	#  we have to remove the volumes on ISO making process, here we launch it to create the volumes from scratch

	cd $SCRIPT_PATH/apps/waziup/wazigate-lora
	sudo docker-compose up -d  --no-build
	
fi;

sleep 2

#------------#

cd $SCRIPT_PATH

# Resolving the issue of not having internet within the containers
sudo bash -c "echo -e 'nameserver 8.8.8.8' > /etc/resolv.conf"

docker network create wazigate

#Starting the docker containers # We may remove this later or completely change it
if [ $DEVMODE == 1 ]; then
	echo "[ Notice ]: Running in developer mode"
	sudo docker-compose up -d
	
	cd ./apps/waziup/wazigate-system
	sudo docker-compose up -d
else
	sudo docker-compose up -d  --no-build
fi

cd $SCRIPT_PATH

#------------#

exit 0;