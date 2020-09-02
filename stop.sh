#!/bin/bash
# This file stops wazigate

SCRIPT_PATH=$(dirname $(realpath $0))

#sudo docker-compose stop
sudo docker stop $(sudo docker ps -q)

#Kill wazigate-host
ps ax | grep "wazigate-host" | awk '{print $1}' | sudo xargs kill

#Lunch the wazigate-host service
#sudo bash ./wazigate-host/start.sh &

exit 0;