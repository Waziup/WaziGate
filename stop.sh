#!/bin/bash
# This file stops wazigate

SCRIPT_PATH=$(dirname $(realpath $0))

sudo docker-compose stop

#Lunch the wazigate-host service
#sudo bash ./wazigate-host/start.sh &

exit 0;
