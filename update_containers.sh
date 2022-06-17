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

# Wait for starting of service wazigate
EDGE_STATUS=
while [ "$EDGE_STATUS" != "active" ]
do
  EDGE_STATUS=`systemctl is-active wazigate`
  echo -n "."
  sleep 2
done
echo "Done"
