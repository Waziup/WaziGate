#!/bin/bash
set -x

if [ -f  /sys/class/net/eth0/address ] ; then
  WAZIGATE_ID=$(cat /sys/class/net/eth0/address)
else
  if [ -f  /sys/class/net/wlan0/address ] ; then
    WAZIGATE_ID=$(cat /sys/class/net/wlan0/address)
  fi;
fi;
WAZIGATE_ID=${WAZIGATE_ID//:}

SSID="WAZIGATE_${WAZIGATE_ID^^}"

cd /var/lib/wazigate/
docker-compose down
docker-compose pull
docker-compose up -d

while [ "`docker inspect -f {{.State.Health.Status}} waziup.wazigate-edge`" != "healthy" ]
do
  echo "."
  sleep 2
done

echo "Done"
