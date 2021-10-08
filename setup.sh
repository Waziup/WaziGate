#!/bin/bash -e

if [ -f  /sys/class/net/eth0/address ] ; then
	WAZIGATE_ID=$(cat /sys/class/net/eth0/address)
else
	if [ -f  /sys/class/net/wlan0/address ] ; then
		WAZIGATE_ID=$(cat /sys/class/net/wlan0/address)
	fi;
fi;
WAZIGATE_ID=${WAZIGATE_ID//:}

SSID="WAZIGATE_${WAZIGATE_ID^^}"
sed -i "s/^ssid.*/ssid=$SSID/g" /etc/hostapd/hostapd.conf

# Create the docker network and containers if they do not exist
if ! docker network inspect wazigate > /dev/null; then
  echo "Creating network 'wazigate' ..."
  docker network create wazigate
fi

if ! docker image inspect wazigate-mongo --format {{.Id}} > /dev/null; then
  echo "Creating container 'wazigate-mongo' (MongoDB) ..."
  # docker image save webhippie/mongodb -o wazigate-mongo.tar
  docker image load -i wazigate-mongo.tar
  docker run -d --restart=always --network=wazigate --name wazigate-mongo \
	-p "27017:27017" \
	-v "$PWD/wazigate-mongo/data:/var/lib/mongodb" \
	-v "$PWD/wazigate-mongo/backup:/var/lib/backup" \
	-v "$PWD/wazigate-mongo/bin:/var/lib/bin" \
	--health-cmd="echo 'db.stats().ok' | mongo localhost:27017/local --quiet" \
	--health-interval=10s \
	--entrypoint="sh" \
	webhippie/mongodb \
	/var/lib/bin/entrypoint.sh
fi

if ! docker image inspect wazigate-edge --format {{.Id}} > /dev/null; then
  echo "Creating container 'wazigate-edge' (Wazigate Edge) ..."
  # docker image save waziup/wazigate-edge -o wazigate-edge.tar
  docker image load -i wazigate-edge.tar
  docker run -d --restart=always --network=wazigate --name wazigate-edge \
  	-e "WAZIGATE_ID=$WAZIGATE_ID" \
	-p "80:80" -p "1883:1883" \
	waziup/wazigate-edge
fi
