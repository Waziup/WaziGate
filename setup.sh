#!/bin/bash -e

source .env

log () {
  echo "Step $1/4: $2" > /tmp/wazigate-setup-step.txt
}

# Delete all connections associated with "WAZIGATE-AP"
delete_connections () {
  nmcli c down WAZIGATE-AP
  nmcli connection delete uuid $(nmcli -f NAME,UUID -p c | grep WAZIGATE-AP | sed 's/WAZIGATE-AP//' | xargs)
  rm -rf /etc/NetworkManager/system-connections/*
}

# Setup a new "WAZIGATE-AP" connection
setup_new_connection () {
  nmcli dev wifi hotspot ifname wlan0 con-name WAZIGATE-AP ssid $SSID password "loragateway"
  nmcli connection modify WAZIGATE-AP \
    connection.autoconnect true connection.autoconnect-priority -100 \
    802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared ipv6.method auto \
    wifi-sec.key-mgmt wpa-psk wifi-sec.proto wpa
  # using down/up instead of reapply because '802-11-wireless.band' can not be changed on the fly
  nmcli c down WAZIGATE-AP
  nmcli c up WAZIGATE-AP
}


################################################################################

log 0 "Prepare"

if [ -f  /sys/class/net/eth0/address ] ; then
  WAZIGATE_ID=$(cat /sys/class/net/eth0/address)
else
  if [ -f  /sys/class/net/wlan0/address ] ; then
    WAZIGATE_ID=$(cat /sys/class/net/wlan0/address)
  fi;
fi;
export WAZIGATE_ID=${WAZIGATE_ID//:}

sed -i "s/^WAZIGATE_ID.*/WAZIGATE_ID=$WAZIGATE_ID/g" .env

SSID="WAZIGATE_${WAZIGATE_ID^^}"

################################################################################

log 1 "Enabling interfaces"

# Enable SPI
echo "Enabling SPI ..."
raspi-config nonint do_spi 0
# Enable I2C
echo "Enabling I2C ..."
raspi-config nonint do_i2c 0

################################################################################

log 2 "Configuring Access Point"

echo "Current MAC: $WAZIGATE_ID"
if [ -f /etc/NetworkManager/system-connections/WAZIGATE-AP.nmconnection ]; then
  declare -a IFS=$'' waziAPs=($(nmcli c show WAZIGATE-AP | grep "802-11-wireless.ssid" | sed 's/802-11-wireless.ssid://' | xargs ))

  for OUTPUT in ${waziAPs[@]}
  do
    #echo "${OUTPUT#*_}"
    if [ ${SSID#*_} != ${OUTPUT#*_} ]; then
      echo "Foud other MAC in NetworkManager: ${OUTPUT#*_}"
      delete_connections #"$waziAPs"
    fi
  done
else
  echo "Setup a new connection"
  setup_new_connection
fi

################################################################################

log 3 "Loading docker Iamges"
# Read from docker compose: load images
docker load -i wazigate_images.tar

log 4 "Starting docker containers"
# Create containers
docker-compose up -d
