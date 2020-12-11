#!/bin/bash
# This file creates an SD card image out of the current running system and moves it to the Moji's PC

#-----------------------#

# -- Prepration:
# sudo apt-get install -y samba
# git clone https://github.com/scruss/RonR-RaspberryPi-image-utils.git image-utils
# cd image-utils
# sudo chmod +x *
# sudo mkdir /media/remote
# sudo chown -R pi:pi /media/remote

# -- Running for the first time:

# sudo /home/pi/image-utils/image-backup 
# /media/usb/backup.img
# y

#-----------------------#

sudo mkdir -p /media/remote

echo -e "Mounting the remote directory...\nEnter the password: \t123\n"

sudo mount -t cifs //10.42.0.1/share /media/remote -o username=gholi

if mount | grep /media/remote > /dev/null; then
    echo -e "Mounted SUccessfully\n\n"
else
    echo -e "Error: mounting failed!\n\n"
	exit 1;
fi

#-----------------------#

echo -e "Reverting Wazigate to its default values..."

cd /home/pi/waziup-gateway/
#sudo docker-compose stop
sudo docker stop $(sudo docker ps -q)
sudo rm -f /home/pi/waziup-gateway/.default_ap_done
cp /home/pi/waziup-gateway/setup/clouds.json /home/pi/waziup-gateway/wazigate-edge/
#sudo cp /home/pi/waziup-gateway/setup/conf.default.json /home/pi/waziup-gateway/wazigate-system/conf/conf.json
sudo rm -f -r /home/pi/waziup-gateway/wazigate-mongo/data

#sudo docker rm -f postgresql redis
cd /home/pi/waziup-gateway/waziup-gateway/apps/waziup/wazigate-lora && \
sudo docker-compose down && \
sudo docker volume rm $(sudo docker volume ls -q)

echo -e "Done.\n"

#-----------------------#

cd /home/pi/waziup-gateway/setup/

if [ ! -f /media/remote/wazigate.img ] ; then

	echo -e "Creating a new image...\nUse this path:\t/media/remote/wazigate.img"
	sudo ./image-utils/image-backup

else
	echo "Updating the image..."
	sudo ./image-utils/image-backup /media/remote/wazigate.img

fi;

#echo -e "Done\n\n"

#echo "Copying the image to Moji's PC..."
#smbclient -U moji //192.168.0.116/share -c "put /media/usb/backup.img WazigateLatest.img" 123

echo -e "All done :) \n\n"

#-----------------------#
exit 0;
