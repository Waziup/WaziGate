#!/bin/bash
set -x

cd /var/lib/wazigate/

# Switch everything down
sudo systemctl restart docker
docker-compose down
sleep 5

# Load new image
if [ -f wazigate_images.tar ]; then
  docker load -i wazigate_images.tar
  sudo rm -f wazigate_images.tar
fi

# Restart
docker-compose up -d 

# Wait for starting
SYSTEM_STATUS=
while [ "$SYSTEM_STATUS" != "healthy" ]
do
  SYSTEM_STATUS=`docker inspect -f {{.State.Health.Status}} waziup.wazigate-system 2>/dev/null`
  echo -n "."
  sleep 2
done
echo "Done"
