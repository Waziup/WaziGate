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
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    -v "/var/run/wazigate-host.sock:/var/run/wazigate-host.sock" \
    -v "$PWD/apps:/root/apps" \
    -p "80:80" -p "1883:1883" \
    waziup/wazigate-edge
fi

if ! docker image inspect waziup/wazigate-system --format {{.Id}} > /dev/null; then
  echo "Creating container 'wazigate-system' (Wazigate System) ..."
  # docker image save waziup/wazigate-system -o wazigate-system.tar
  docker image load -i wazigate-system.tar
  docker run -d --network=host --name waziup.wazigate-system \
    -v "$PWD/apps/waziup.wazigate-system:/var/lib/waziapp" \
    -v "/var/run:/var/run" \
    -v "/sys/class/gpio:/sys/class/gpio" \
    -v "/dev/mem:/dev/mem" \
    --privileged \
    --health-cmd="curl --fail --unix-socket /var/lib/waziapp/proxy.sock http://localhost/ || exit 1" \
    --health-interval=10s \
    waziup/wazigate-system
fi
