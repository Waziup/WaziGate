Introduction
============

The **low_level_lora_gw** folder contains the low-level radio bridge program to be run on a Raspberry. This program receives LoRa packets from remote end-devices.

The **high_level_lora_gw** folder contains the higher level functionalities of the gateway such as data processing tasks. A typical processing task is to push received data to Internet servers or dedicated (public or private) IoT clouds. We provide a post_processing_gw.py Python script and template that already implements data uploading to various public IoT clouds. You can customize it for your own needs.

The **gw_full_latest** folder contains the latest version of the full gateway (low-level+high-level). It is recommended to use get this full version.

You first need to have a running Raspberry. You can install a whole new Raspbian (Jessie recommended) system on an SD card, but we recommended you to download our SD card image and to flash it on an 8GB SD card.

- get the zipped SD card image (Raspbian Jessie)
	- [raspberrypi-jessie-WAZIUP-demo.dmg.zip](http://cpham.perso.univ-pau.fr/LORA/WAZIUP/raspberrypi-jessie-WAZIUP-demo.dmg.zip)
	- Based on Raspbian Jessie 
	- Supports Raspberry 1B+, RPI2 and RPI3 (WiFi support is for RPI3. For RPI1 and RPI2 see [here](https://github.com/Waziup/waziup-gateway/blob/master/high_level_lora_gw/README.md#wifi-instructions-on-rpi1b-and-rpi2) for modifications to support some WiFi dongles)
	- Get the zipped image, unzip it, install it on an 8GB SD card, see [this tutorial](https://www.raspberrypi.org/documentation/installation/installing-images/) from www.raspberrypi.org
	- Plug the SD card into your Raspberry
	- Connect a radio module (see http://cpham.perso.univ-pau.fr/LORA/RPIgateway.html)
	- Power-on the Raspberry
	- pi user
		- login: pi
		- password: loragateway
		- **it is strongly advise to change the pi user's password**		
	- The LoRa gateway starts automatically when RPI is powered on
	- With an RPI3, the Raspberry will automatically act as a WiFi access point
		- SSID=WAZIUP_PI_GW_27EB27F90F
		- password=loragateway
		- **it is strongly advise to change this WiFi password**
	- Then, update the gateway distribution with latest version from the github (see below) and reboot
			
Get the latest gateway version 
==============================

The full, latest distribution of the low-cost gateway is available in the gw_full_latest folder. It contains all the gateway control and post-processing software. If you use our SD card image and update the gateway from it you don't need to install any additional packages. Otherwise you may need to install required Raspbian Jessie packages as explained in the various README files.

To get directly to the full, latest gateway version, (i) simply download (git clone) the whole repository and copy the entire content of the gw_full_latest folder on your Raspberry, in a folder named lora_gateway or, (ii) get only (svn checkout) the gw_full_latest folder in a folder named lora_gateway. 

First option
------------

Get all the repository:

	> git clone https://github.com/Waziup/waziup-gateway.git
	
You will get the entire repository:

	pi@raspberrypi:~ $ ls -l waziup-gateway/
	total 32
	drwxr-xr-x 7 pi pi  4096 Apr  1 15:38 gw_full_latest
	drwxr-xr-x 7 pi pi  4096 Apr  1 15:38 high_level_lora_gw
	drwxr-xr-x 7 pi pi  4096 Apr  1 15:38 low_level_lora_gw		
	-rw-r--r-- 1 pi pi 15522 Apr  1 15:38 README.md	
	
Create a folder named "lora_gateway" for instance then copy all the files of the waziup-gateway/gw_full_latest folder in it.

    > mkdir lora_gateway
    > cd lora_gateway
    > cp -R ../waziup-gateway/gw_full_latest/* .
    
Or if you want to "move" the waziup-gateway/gw_full_latest folder, simply do (without creating the lora_gateway folder before):

	> mv waziup-gateway/gw_full_latest ./lora_gateway    

Second option
-------------

Get only the gateway part:

	> svn checkout https://github.com/Waziup/waziup-gateway/trunk/gw_full_latest lora_gateway
	
That will create the lora_gateway folder and get all the file of (GitHub) waziup-gateway/gw_full_latest in it. Then:

	> cd lora_gateway

Note that you may have to install svn before being able to use the svn command:

	> sudo apt-get install subversion

Then, in the script folder, run config_gw.sh to configure your gateway, as described [here](https://github.com/Waziup/waziup-gateway/blob/master/gw_full_latest/README.md#configure-your-gateway-with-config_gwsh). After configuration, reboot your Raspberry. 

By default gateway_conf.json configures the gateway with a simple behavior: LoRa mode 1 (BW125SF12), no DHT sensor in gateway (so no MongoDB for DHT sensor), no downlink, no AES, no raw mode. clouds.json enables only the ThingSpeak demo channel (even the local MongoDB storage is disabled). You can customize your gateway later when you have more cloud accounts and when you know better what features you want to enable.

The LoRa gateway starts automatically when RPI is powered on. Then use cmd.sh to execute the main operations on the gateway as described in [here](https://github.com/Waziup/waziup-gateway/blob/master/gw_full_latest/README.md#use-cmdsh-to-interact-with-the-gateway).	

With the latest gateway version on the github, you also have in lora_gateway/scripts an update_gw.sh script that updates your gateway with future latest versions. Simple go into lora_gateway/scripts and type:

	> ./update_gw.sh
	
If you have an existing /home/pi/lora_gateway folder, then it will preserve all you existing configuration files (i.e. key_*, gateway_conf.json, clouds.json and radio.makefile). As the repository does not have a gateway_id.txt file, it will also preserve your gateway id.

**Note that you can also use this script to install a completely new gateway with the latest gateway version** by downloading from the github the gw_full_latest/scripts/update_gw.sh script (switch in raw mode and save the script on your computer), copy it on your Raspberry gateway (using scp for instance) in /home/pi and then simply run the script (you may need to add execution right with chmod +x update_gw.sh).	
