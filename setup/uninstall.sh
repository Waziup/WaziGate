#!/bin/bash
# Uuinstalling the WaziGate framework from your device
# @author: Mojiz 01 Jul 2019

SCRIPT_PATH=$(dirname $(realpath $0))


echo "$SCRIPT_PATH/../../waziup-gateway";

cd "$SCRIPT_PATH/../../"

if [ -d "waziup-gateway" ]; then
	echo "RUN Uninstall script"
	
	cd waziup-gateway
	docker-compose stop
	docker system prune -fa
	docker rm $(docker ps -a -q)
	docker rmi -f $(docker images -a -q)
	cd ..

	newName="waziup-gateway_OLD_$((RANDOM % 100000))"
	mv waziup-gateway "$newName"
	
	#Removing the autostart script
	sed -i 's/^.*waziup-gateway.*//g' /etc/rc.local
	
	sudo sed -i 's/^.*DAEMON_CONF=.*//g' /etc/default/hostapd
	sudo sed -i 's/^net.ipv4.ip_forward=.*//g' /etc/sysctl.conf
	
	echo -e "\n\tUninstalling finished.\n"
fi