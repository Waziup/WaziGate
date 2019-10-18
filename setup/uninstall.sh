#!/bin/bash
# Uuinstalling the WaziGate framework from your device
# @author: Mojiz 01 Jul 2019

INSTALL_DIR=$HOME

read -p "This script will delete all Waziup software and configuration. Are you sure (y/n)? "
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Existing."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo "Deleting comtainers..."
cd $INSTALL_DIR/waziup-gateway
sudo docker-compose stop
sudo docker system prune -fa
sudo docker rm $(docker ps -a -q)
sudo docker rmi -f $(docker images -a -q)
cd ..

echo "Deleting waziup-gateway folder..."
sudo rm -rf $INSTALL_DIR/waziup-gateway

echo "Removing system configation..."
sudo sed -i 's/^.*waziup-gateway.*//g' /etc/rc.local
sudo sed -i 's/^.*DAEMON_CONF=.*//g' /etc/default/hostapd
sudo sed -i 's/^net.ipv4.ip_forward=.*//g' /etc/sysctl.conf

echo -e "\nUninstalling finished.\n"
