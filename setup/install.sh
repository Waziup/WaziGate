#!/bin/bash
# Installing the WaziGate framework on your device
# @author: Mojiz 20 Jun 2019

WAZIUP_ROOT=$HOME/waziup-gateway

read -p "This script will configure Wazigate on your system. Continue (y/n)? "
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Existing."
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

echo "Installing system-wide packages..."
sudo apt-get update
sudo apt-get install -y git network-manager python3 python3-pip dnsmasq hostapd connectd i2c-tools libopenjp2-7 libtiff5
sudo -H pip3 install flask psutil luma.oled

#Docker
sudo curl -fsSL get.docker.com -o get-docker.sh 
sudo sh get-docker.sh
sudo usermod -aG docker $USER
sudo rm get-docker.sh
echo "Done"

#-----------------------#

echo "Configuring Wazigate software..."
cd $WAZIUP_ROOT/
sudo cp setup/docker-compose /usr/bin/ && sudo chmod +x /usr/bin/docker-compose
sudo mkdir -p wazigate-ui/conf
sudo chown $USER -R wazigate-ui/conf

sudo mkdir -p wazigate-edge/conf
sudo cp setup/clouds.json wazigate-edge/conf/
sudo chown $USER -R wazigate-edge/conf
echo "Done"

echo "Downloading the docker images..."
docker-compose pull
echo "Done"

#-----------------------#

#Setup I2C (http://www.runeaudio.com/forum/how-to-enable-i2c-t1287.html)
echo "Configuring the system..."
if ! grep -qFx "dtparam=i2c_arm=on" /boot/config.txt; then
  echo -e '\ndtparam=i2c_arm=on' | sudo tee -a /boot/config.txt
fi
if ! grep -qF "bcm2708.vc_i2c_override=1" /boot/cmdline.txt; then
  sudo bash -c "echo -n ' bcm2708.vc_i2c_override=1' >> /boot/cmdline.txt"
fi
if ! grep -qFx "i2c-bcm2708" /etc/modules-load.d/raspberrypi.conf; then
  echo -e '\ni2c-bcm2708' | sudo tee -a /etc/modules-load.d/raspberrypi.conf
fi
if ! grep -qFx "i2c-dev" /etc/modules-load.d/raspberrypi.conf; then
  echo -e '\ni2c-dev' | sudo tee -a /etc/modules-load.d/raspberrypi.conf
fi

#Setting up the Access Point
sudo systemctl stop dnsmasq; sudo systemctl stop hostapd

sudo mv --backup=numbered /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo bash -c "echo -e 'interface=wlan1\n  dhcp-range=192.168.200.2,192.168.200.200,255.255.255.0,24h\n' > /etc/dnsmasq.conf"
sudo cp setup/hostapd.conf /etc/hostapd/hostapd.conf
if ! grep -qFx 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' /etc/default/hostapd; then
  sudo sed -i -e '$i \DAEMON_CONF="/etc/hostapd/hostapd.conf"\n' /etc/default/hostapd
fi

sudo cp --backup=numbered setup/interfaces_ap /etc/network/interfaces

#Wlan: make a copy of the config file
sudo cp --backup=numbered /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.orig

#Setup autostart
sed -i 's/^DEVMODE.*/DEVMODE=0/g' start.sh
if ! grep -qF "start.sh" /etc/rc.local; then
  sudo sed -i -e '$i \cd '"$PWD"'; sudo bash ./start.sh &\n' /etc/rc.local
fi
echo "Done"

#------------------------#

#Remote.it Credentials
if [ "$REMOTE" != "" ]; then
	arrIN=($REMOTE)
	echo -e "email=\"${arrIN[0]}\"\npassword=\"${arrIN[1]}\"" > remote.it/creds
fi

#------------------------#

echo "Installation finished. For the changes to take effect, please reboot."

exit 0;
