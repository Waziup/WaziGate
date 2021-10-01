#!/bin/bash -e

# Set the SSID for Access Point using the Raspberry Pi MAC address
if [ ! -f .default_ap_done ] ; then

	MAC="Access_Point"

	if [ -f  /sys/class/net/eth0/address ] ; then
		MAC=$(cat /sys/class/net/eth0/address)
	else
		if [ -f  /sys/class/net/wlan0/address ] ; then
			MAC=$(cat /sys/class/net/wlan0/address)
		fi;
	fi;

	MAC=${MAC//:}
	SSID="WAZIGATE_${MAC^^}"
	sudo sed -i "s/^ssid.*/ssid=$SSID/g" /etc/hostapd/hostapd.conf

	touch .default_ap_done	
fi;

# Create the docker network and containers if they do not exist
if ! docker network inspect wazigate > /dev/null; then
  echo "Creating network 'wazigate' ..."
  docker network create wazigate
fi

if ! docker image inspect wazigate-mongo --format {{.Id}} > /dev/null; then
  echo "Creating container 'wazigate-mongo' (MongoDB) ..."
  # docker image save webhippie/mongodb -o wazigate-mongo.tar
  docker image load -i wazigate-mongo.tar
  docker-compose run wazigate-mongo
fi

if ! docker image inspect wazigate-edge --format {{.Id}} > /dev/null; then
  echo "Creating container 'wazigate-edge' (Wazigate Edge) ..."
  # docker image save waziup/wazigate-edge -o wazigate-edge.tar
  docker image load -i wazigate-edge.tar
  docker-compose run wazigate-edge
fi
