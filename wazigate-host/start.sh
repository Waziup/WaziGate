#!/bin/bash
SCRIPT_PATH=$(dirname $(realpath $0))
sudo chmod +x $SCRIPT_PATH/wazigate-host

#Restart always...
while :
do
	if [ "$1" == "1" ]; then
		#Debug Mode (stores logs into a file "host.logs")
		sudo $SCRIPT_PATH/wazigate-host -d 1
	
	else
		sudo $SCRIPT_PATH/wazigate-host
	fi

	sleep 1
done
