#!/bin/bash -e

source .env

log () {
  echo "Step $1/5: ${2}This might take several minutes." > /tmp/wazigate-setup-step.txt
}

# Delete all connections associated with "WAZIGATE-AP"
delete_connections () {
  #nmcli c down WAZIGATE-AP
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

# Image backup: a copy of all compose images, used as last resort if the images
# stored in docker are corrupted. The .ids file records which image IDs the tar
# contains, so it is only rewritten when images actually changed (e.g. via update.sh).
IMAGE_BACKUP=wazigate_images.backup.tar
IMAGE_BACKUP_IDS=wazigate_images.backup.ids

# Image list as array: the access point setup below sets IFS='' globally, so
# unquoted $(...) would not be split into words anymore.
compose_images () {
  mapfile -t COMPOSE_IMAGES < <(docker-compose config --images 2>/dev/null)
  [ ${#COMPOSE_IMAGES[@]} -gt 0 ]
}

# Sorted image IDs. "docker-compose config --images" returns the images in a
# random order on every call, an unsorted list would never match the stored one.
image_ids_of () {
  local out
  out=$(docker image inspect --format '{{.Id}}' "$@") || return 1
  sort <<<"$out"
}

current_image_ids () {
  compose_images || return 1
  image_ids_of "${COMPOSE_IMAGES[@]}"
}

update_image_backup () {
  local ids platform
  # Not inside $(...): COMPOSE_IMAGES must be set in this shell for docker save
  compose_images || { echo "Image backup: could not list compose images, skipping."; return 0; }
  ids=$(image_ids_of "${COMPOSE_IMAGES[@]}") \
    || { echo "Image backup: could not read image IDs, skipping."; return 0; }
  if [ -f "$IMAGE_BACKUP" ] && [ "$ids" == "$(cat "$IMAGE_BACKUP_IDS" 2>/dev/null)" ]; then
    return 0
  fi
  echo "Images changed, updating image backup (${#COMPOSE_IMAGES[@]} images) ..."
  # With the containerd image store, saving images pulled from multi-arch
  # indexes can fail (other platforms missing locally): retry for this platform.
  platform=$(docker version --format '{{.Server.Os}}/{{.Server.Arch}}' 2>/dev/null)
  if docker save -o "$IMAGE_BACKUP.tmp" "${COMPOSE_IMAGES[@]}" \
     || { [ -n "$platform" ] && echo "Retrying docker save for $platform ..." \
          && docker save --platform "$platform" -o "$IMAGE_BACKUP.tmp" "${COMPOSE_IMAGES[@]}"; }; then
    mv -f "$IMAGE_BACKUP.tmp" "$IMAGE_BACKUP"
    echo "$ids" > "$IMAGE_BACKUP_IDS"
    sync
    echo "Image backup written: $(du -h "$IMAGE_BACKUP" | cut -f1)"
  else
    echo "Image backup: docker save failed, keeping old backup."
    rm -f "$IMAGE_BACKUP.tmp"
  fi
}


################################################################################

log 0 "Prepare: "

if [ -f  /sys/class/net/eth0/address ] ; then
  WAZIGATE_ID=$(cat /sys/class/net/eth0/address)
elif [ -f  /sys/class/net/wlan0/address ] ; then
  WAZIGATE_ID=$(cat /sys/class/net/wlan0/address)
fi;
export WAZIGATE_ID=${WAZIGATE_ID//:}
SSID="WAZIGATE_${WAZIGATE_ID^^}"

################################################################################

log 1 "Enabling interfaces: "

# Enable SPI
echo "Enabling SPI ..."
raspi-config nonint do_spi 0
# Enable I2C
echo "Enabling I2C ..."
raspi-config nonint do_i2c 0

################################################################################

log 2 "Configuring Access Point: "

echo "Current MAC: $WAZIGATE_ID"
if [ -f /etc/NetworkManager/system-connections/WAZIGATE-AP.nmconnection ]; then
  declare -a IFS=$'' waziAPs=($(nmcli c show WAZIGATE-AP | grep "802-11-wireless.ssid" | sed 's/802-11-wireless.ssid://' | xargs ))

  for OUTPUT in ${waziAPs[@]}
  do
    #echo "${OUTPUT#*_}"
    if [ ${SSID#*_} != ${OUTPUT#*_} ]; then
      echo "Found other MAC in NetworkManager: ${OUTPUT#*_}"
      delete_connections #"$waziAPs"
    fi
  done
  # After deleting old "WAZIGATE-AP" connections, create a new one
  if [ ! -f /etc/NetworkManager/system-connections/WAZIGATE-AP.nmconnection ]; then
    echo "Setup a new connection"
    setup_new_connection
  fi
else
  # Create a new "WAZIGATE-AP" connection, if there are no connections 
  echo "Setup a new connection"
  setup_new_connection
fi

################################################################################

log 3 "Loading docker images: "
# Read from docker compose: load images
if [ -f wazigate_images.tar ]; then
  docker load -i wazigate_images.tar
  # The tar contains exactly the compose images (see Jenkinsfile), keep it as backup
  mv -f wazigate_images.tar "$IMAGE_BACKUP"
  current_image_ids > "$IMAGE_BACKUP_IDS" || rm -f "$IMAGE_BACKUP_IDS"
fi

################################################################################

log 4 "Updating redis.sock file permissions"
sudo chmod 777 /var/run/redis/redis.sock

################################################################################

log 5 "Updating wait-for-wazigate-edge.sh file permissions"
sudo chmod u+x /var/lib/wazigate/apps/waziup.wazigate-lora/mosquitto/config/wait-for-wazigate-edge.sh

################################################################################
log 6 "Starting docker containers: "
# Start containers. After an unclean shutdown or SD card write error, a container's
# rootfs snapshot can be corrupted (e.g. "lstat /var/lib/docker/rootfs/overlayfs/<id>/etc:
# not a directory"). In that case remove the containers and recreate them from the
# existing images. If the images themselves are corrupted, restore them from the
# image backup. Data lives in bind mounts and named volumes (postgresqldata),
# which are kept (no -v flag).
if ! docker-compose up -d; then
  echo "docker-compose up failed, removing and recreating containers from images ..."
  docker-compose rm -f -s || true
  if ! docker-compose up -d --force-recreate; then
    if [ ! -f "$IMAGE_BACKUP" ]; then
      echo "Recreating containers failed and no image backup found."
      exit 1
    fi
    echo "Recreating containers failed, restoring images from $IMAGE_BACKUP ..."
    # Remove containers and the (possibly corrupted) images first, otherwise
    # docker load may reuse the broken local content.
    docker-compose down --rmi all || true
    docker load -i "$IMAGE_BACKUP"
    docker-compose up -d
  fi
fi

# Containers are running, so the current images are good: refresh the backup if they changed
update_image_backup