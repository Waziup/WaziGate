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
			
Installing the latest gateway version 
=====================================

The full, latest distribution of the low-cost gateway is available in the gw_full_latest folder of the github. It contains all the gateway control and post-processing software. The **simplest and recommended way** to install a new gateway is to use [our zipped SD card image](http://cpham.perso.univ-pau.fr/LORA/WAZIUP/raspberrypi-jessie-WAZIUP-demo.dmg.zip) and update the gateway from it. In this way you don't need to install any additional packages. Otherwise you may need to install required Raspbian Jessie packages as explained in the various README files.

Once you have your SD card flashed with our image, to get directly to the full, latest gateway version, you can either (i) use the provided update script, or (ii) download (git clone) the whole repository and copy the entire content of the gw_full_latest folder on your Raspberry, in a folder named lora_gateway or, (iii) get only (svn checkout) the gw_full_latest folder in a folder named lora_gateway. Option (i) is preferable and basically automatizes option (iii).

First option
------------

The SD card image has a recent version of the gateway software and there is in the lora_gateway/scripts folder an update_gw.sh script that automatically updates your gateway to the latest version. Simply go into lora_gateway/scripts and type:

	> ./update_gw.sh
	
If you have an existing /home/pi/lora_gateway folder, then it will preserve all you existing configuration files (i.e. key_*, gateway_conf.json, clouds.json and radio.makefile). As the repository does not have a gateway_id.txt file, it will also preserve your gateway id.

Second option
-------------

Get all the repository:

	> git clone https://github.com/Waziup/waziup-gateway.git
	
You will get the entire repository:

	pi@raspberrypi:~ $ ls -l waziup-gateway/
	total 32
	drwxr-xr-x 7 pi pi  4096 Apr  1 15:38 gw_full_latest
	drwxr-xr-x 7 pi pi  4096 Apr  1 15:38 high_level_lora_gw
	drwxr-xr-x 7 pi pi  4096 Apr  1 15:38 low_level_lora_gw		
	-rw-r--r-- 1 pi pi 15522 Apr  1 15:38 README.md	
	
Create a folder named "lora_gateway" (or if you already have one, then delete all its content) then copy all the files of the waziup-gateway/gw_full_latest folder in it.

    > mkdir lora_gateway
    > cd lora_gateway
    > cp -R ../waziup-gateway/gw_full_latest/* .
    
Or if you want to "move" the waziup-gateway/gw_full_latest folder, simply do (without creating the lora_gateway folder before):

	> mv waziup-gateway/gw_full_latest ./lora_gateway    

Third option
------------

Get only the gateway part:

	> svn checkout https://github.com/Waziup/waziup-gateway/trunk/gw_full_latest lora_gateway
	
That will create the lora_gateway folder and get all the file of (GitHub) waziup-gateway/gw_full_latest in it. Then:

	> cd lora_gateway
	
Note that you may have to install svn before being able to use the svn command (if you installed from our SD card image, svn is already installed):

	> sudo apt-get install subversion	

Configuring your gateway after update
-------------------------------------

After gateway update, you need to configure your new gateway, mainly by assigning the gateway id so that it is uniquely identified (the gateway's WiFi access point SSID is based on that gateway id for instance). The gateway id will be the last 5 bytes of the Rapberry eth0 MAC address and the configuration script will extract this information for you. In the script folder, simply run basic_config_gw.sh to automatically configure your gateway. 

	> ./basic_config_gw.sh
	
If you need more advanced configuration, then run config_gw.sh as described [here](https://github.com/Waziup/waziup-gateway/blob/master/gw_full_latest/README.md#configure-your-gateway-with-config_gwsh). However, basic_config_gw.sh should be sufficient for most of the cases. After configuration, reboot your Raspberry. 

By default gateway_conf.json configures the gateway with a simple behavior: LoRa mode 1 (BW125SF12), no DHT sensor in gateway (so no MongoDB for DHT sensor), no downlink, no AES, no raw mode. clouds.json enables only the ThingSpeak demo channel (even the local MongoDB storage is disabled). You can customize your gateway later when you have more cloud accounts and when you know better what features you want to enable.

The LoRa gateway starts automatically when RPI is powered on. Then use cmd.sh to execute the main operations on the gateway as described in [here](https://github.com/Waziup/waziup-gateway/blob/master/gw_full_latest/README.md#use-cmdsh-to-interact-with-the-gateway).		

