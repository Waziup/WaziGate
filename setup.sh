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

source .env

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
    -e "WAZIGATE_VERSION=$WAZIGATE_VERSION" \
    -e "WAZIGATE_TAG=$WAZIGATE_TAG" \
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
  docker run -d --restart=unless-stopped --network=host --name waziup.wazigate-system \
    -v "$PWD/apps/waziup.wazigate-system:/var/lib/waziapp" \
    -v "/var/run:/var/run" \
    -v "/sys/class/gpio:/sys/class/gpio" \
    -v "/dev/mem:/dev/mem" \
    --privileged \
    --health-cmd="curl --fail --unix-socket /var/lib/waziapp/proxy.sock http://localhost/ || exit 1" \
    --health-interval=10s \
    waziup/wazigate-system
fi

################################################################################

if ! docker image inspect waziup/wazigate-lora --format {{.Id}} > /dev/null; then
  docker volume create postgresqldata
  docker volume create redisdata

  echo "Creating container 'waziup.wazigate-lora.forwarders' (Wazigate-LoRa App - Forwarders) ..."
  docker image load -i wazigate-lora-forwarders.tar
  docker run -d --restart=unless-stopped --network=wazigate --name "waziup.wazigate-lora.forwarders" \
    -v "$PWD/apps/waziup.wazigate-lora/forwarders/conf/:/root/conf" \
    -v "/var/run/dbus:/var/run/dbus" \
    -v "/sys/class/gpio:/sys/class/gpio" \
    -v "/dev:/dev" \
    --device "/dev/ttyACM0:/dev/ttyACM0" \
    --privileged \
    --tty \
    --label "io.waziup.waziapp=waziup.wazigate-lora" \
    waziup/wazigate-lora-forwarders

  echo "Creating container 'redis' (Wazigate-LoRa App - Redis) ..."
  docker image load -i redis.tar
  docker run -d --restart=unless-stopped --network=wazigate --name redis \
    -v "redisdata:/data" \
    redis:5-alpine

  echo "Creating container 'postgresql' (Wazigate-LoRa App - PostgreSQL) ..."
  docker image load -i postgresql.tar
  docker run -d --restart=unless-stopped --network=wazigate --name postgresql \
    -v "$PWD/apps/waziup.wazigate-lora/conf/postgresql/initdb:/docker-entrypoint-initdb.d" \
    -v "postgresqldata:/var/lib/postgresql/data" \
    -e "POSTGRES_HOST_AUTH_METHOD=trust" \
    waziup/wazigate-postgresql

  echo "Creating container 'chirpstack-gateway-bridge' (Wazigate-LoRa App - ChirptStack Gateway Bridge) ..."
  docker image load -i chirpstack-gateway-bridge.tar
  docker run -d --restart=unless-stopped --network=wazigate --name waziup.wazigate-lora.chirpstack-gateway-bridge \
    -v "$PWD/apps/waziup.wazigate-lora/conf/chirpstack-gateway-bridge:/etc/chirpstack-gateway-bridge" \
    -p "1700:1700/udp" \
    --label "io.waziup.waziapp=waziup.wazigate-lora" \
    waziup/chirpstack-gateway-bridge:3.9.2

  echo "Creating container 'chirpstack-application-server' (Wazigate-LoRa App - ChirptStack Application Server) ..."
  docker image load -i chirpstack-application-server.tar
  docker run -d --restart=unless-stopped --network=wazigate --name waziup.wazigate-lora.chirpstack-application-server \
    -v "$PWD/apps/waziup.wazigate-lora/conf/chirpstack-application-server:/etc/chirpstack-application-server" \
    -p "8080:8080" \
    --label "io.waziup.waziapp=waziup.wazigate-lora" \
    waziup/chirpstack-application-server:3.13.2

  echo "Creating container 'chirpstack-network-server' (Wazigate-LoRa App - ChirptStack Network Server) ..."
  docker image load -i chirpstack-network-server.tar
  docker run -d --restart=unless-stopped --network=wazigate --name waziup.wazigate-lora.chirpstack-network-server \
    -v "$PWD/apps/waziup.wazigate-lora/conf/chirpstack-network-server:/etc/chirpstack-network-server" \
    --label "io.waziup.waziapp=waziup.wazigate-lora" \
    waziup/chirpstack-network-server:3.11.0

  echo "Creating container 'waziup.wazigate-lora' (Wazigate-LoRa App) ..."
  docker image load -i wazigate-lora.tar
  docker run -d --restart=unless-stopped --network=wazigate --name waziup.wazigate-lora \
    -v "$PWD/apps/waziup.wazigate-lora:/var/lib/waziapp" \
    --label "io.waziup.waziapp=waziup.wazigate-lora" \
    waziup/wazigate-lora
fi
