WaziGate LoRa gateway
=====================

This repo contains the source code for the Waziup gateway.

** WARNING: this repo is work in progress. Do not use yet **

Complete instructions for Windows, Linux and MacOS users can be found on the website: http://www.waziup.io/documentation .
The instructions below are for developpers and experts.

Install
=======

To install the Wazigate on a Raspberry PI, [download](https://www.raspberrypi.org/downloads/raspbian/) the latest raspbian and unzip it:
```
wget https://downloads.raspberrypi.org/raspbian_lite_latest
unzip raspbian_lite_latest
```

Flash it on an SD card. You need to find the SD card device ID first:
```
# Find the SD card device:
sudo fdisk -l

# Flash it:
sudo dd if=./<image name>.img of=/dev/<dev name> status=progress bs=4M
```
In the above command, replace with your image name, and with your SD card device (for example: /dev/mmcblk0).
Be extra careful, as if you enter the wrong dev ID, you could overwrite your own hard disk.
After that, you need to mount the SD card on you PC (if it's not already mounted somewhere), and create a file named **ssh** without extention on the SD card.
If it has multiple partitions, just create it on anyone you are allowed to.

```
mount
cd <mount path>
touch ssh
```

You can now extract the SD card from your PC and insert it into the Raspberry PI.
You should also connect the RPI to your PC by Ethernet cable.
SSH into the PI. Password is `raspberry`:
```
ssh pi@raspberrypi.local
```
Then download and install WaziGate with the following command on the RPI terminal:
```
curl -fsSL https://raw.githubusercontent.com/Waziup/waziup-gateway/master/setup/get_waziup.sh | bash
```

This will take a while. Time to grab a cup of tea.
Once finished, the pi will be rebooted and then pulls the containers and set up everything, then reboots again.
Then you can access your Wazigate UI on http://wazigate.local/ !

Develop
=======


For developer version, you need to run the following line:

```
curl -fsSL https://raw.githubusercontent.com/Waziup/waziup-gateway/master/setup/get_waziup_dev.sh | bash
```
This will download the code from github HEAD.


Bulding the images
------------------

You can build the *production* images simply by doing:
```
docker-compose build
```

You can build the *development* images by doing:
```
docker-compose build -f docker-compose-dev.yml
```

The development version will mount volumes for wazigate-system and wazigate-ui, so that modifying the files will be reflected immediatly (without recompiling the docker images).
For instance, if you modify the file `wazigate-ui/index.php`, you just need to refresh your browser to see the result.


Running on a laptop
-------------------

You can run the software on a simple laptop for debugging, however some features won't work (e.g. LoRa).
```
docker-compose -f docker-compose.yml -f docker-compose-i386.yml up
```
The UI is available on [localhost](http://localhost).
It is also possible to add `-f docker-compose-dev.yml` to develop locally.
