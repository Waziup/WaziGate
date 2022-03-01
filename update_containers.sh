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
wait 10
docker-compose pull
wait 10
docker-compose up -d

EDGE_STATUS=
while [ "$EDGE_STATUS" != "healthy" ]
do
  EDGE_STATUS=`docker inspect -f {{.State.Health.Status}} waziup.wazigate-edge`
  echo -n "."
  sleep 2
done
echo "Done"
