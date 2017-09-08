Introduction
============

The **low_level_lora_gw** folder contains the low-level radio bridge program to be run on a Raspberry. This program receives LoRa packets from remote end-devices.

The **high_level_lora_gw** folder contains the higher level functionalities of the gateway such as data processing tasks. A typical processing task is to push received data to Internet servers or dedicated (public or private) IoT clouds. We provide a post_processing_gw.py Python script and template that already implements data uploading to various public IoT clouds. You can customize it for your own needs.

The **gw_full_latest** folder contains the latest version of the full gateway (low-level+high-level). It is recommended to use get this full version.

You first need to have a running Raspberry. You can install a whole new Raspbian (Jessie recommended) system on an SD card, but we recommended you to download our SD card image and to flash it on an 8GB SD card.

- get the zipped SD card image (Raspbian Jessie)
	- [raspberrypi-jessie-WAZIUP-demo.dmg.zip](http://cpham.perso.univ-pau.fr/LORA/WAZIUP/raspberrypi-jessie-WAZIUP-demo.dmg.zip)
	- Based on Raspbian Jessie 
	- Supports Raspberry 1B+, RPI2, RPI3, RPI0 and RPI0W (out-of-box WiFi support is for RPI3 and RPI0W. For RPI1 and RPI2 see [here](https://github.com/CongducPham/LowCostLoRaGw/blob/master/gw_full_latest/README.md#wifi-instructions-on-rpi1b-and-rpi2) for modifications to support some WiFi dongles)
	- Get the zipped image, unzip it, install it on an **8GB** SD card (or bigger), see [this tutorial](https://www.raspberrypi.org/documentation/installation/installing-images/) from www.raspberrypi.org
	- Plug the SD card into your Raspberry
	- Connect a radio module (see http://cpham.perso.univ-pau.fr/LORA/RPIgateway.html)
	- Power-on the Raspberry
	- pi user
		- login: pi
		- password: loragateway
		- **it is strongly advise to change the pi user's password**		
	- The LoRa gateway starts automatically when RPI is powered on
	- With an RPI3 and RPI0W, the Raspberry will automatically act as a WiFi access point
		- SSID=WAZIUP_PI_GW_27EB27F90F
		- password=loragateway
		- **it is strongly advise to change this WiFi password**
	- Then, update the gateway distribution with latest version from the github (see below) and reboot
			
Installing the latest gateway version 
=====================================

The full, latest distribution of the low-cost gateway is available in the gw_full_latest folder of the github. It contains all the gateway control and post-processing software. The **simplest and recommended way** to install a new gateway is to use [our zipped SD card image](http://cpham.perso.univ-pau.fr/LORA/WAZIUP/raspberrypi-jessie-WAZIUP-demo.dmg.zip) and perform a new install of the gateway from this image. In this way you don't need to install the various additional packages that are required (as explained in the various README files). Once you have burnt the SD image on a 8GB (minimum) SD card, insert it in your Raspberry and power it. 

Connect to your new gateway
---------------------------

If you see the WiFi network WAZIUP_PI_GW_XXXXXXXXXX then connect to this WiFi network. The address of the Raspberry is then 192.168.200.1. If you see no WiFi access point (e.g. RP1/RPI2/RPI0 without WiFi dongle), then plug your Raspberry into a DHCP-enabled box/router/network to get an IP address or shared your laptop internet connection to make your laptop acting as a DHCP server. On a Mac, there is a very simple solution [here](https://mycyberuniverse.com/mac-os/connect-to-raspberry-pi-from-a-mac-using-ethernet.html). For Windows, you can follow [this tutorial](http://www.instructables.com/id/Direct-Network-Connection-between-Windows-PC-and-R/) or [this one](https://electrosome.com/raspberry-pi-ethernet-direct-windows-pc/). You can then use [Angry IP Scanner](http://angryip.org/) to determine the assigned IP address for the Raspberry.

We will use in this example 192.168.2.8 for the gateway address (DHCP option in order to have Internet access from the Raspberry)

	> ssh pi@192.168.2.8
	pi@192.168.200.1's password: 
	
	The programs included with the Debian GNU/Linux system are free software;
	the exact distribution terms for each program are described in the
	individual files in /usr/share/doc/*/copyright.
	
	Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
	permitted by applicable law.
	Last login: Thu Aug  4 18:04:41 2016
	
**For the Raspberry Zero**, our SD card image set the RPI in access point mode. However, when in access-point mode, Ethernet over USB with dtoverlay=dwc2 in /boot/config.txt and modules-load=dwc2,g_ether /boot/cmdline.txt is not working. As the usage of the Raspberry Zero is mainly with Internet connection through a cellular network (using for instance the LORANGA board from La Fabrica Alegre) the easiest way to have Internet through Ethernet sharing with our SD card image is to use a USB-Ethernet adapter that will add an eth0 interface on the RPI0. These USB-Ethernet adapter are quite cheap and are really useful on the RPI0 as you can then connect it to a DHCP-enabled router/box just like the other RPI boards.

Upgrade to the latest gateway version	
-------------------------------------

Once you have your SD card flashed with our image, to get directly to the full, latest gateway version, you can either (i) use the provided update script to be run from the gateway, or (ii) download (git clone) the whole repository and copy the entire content of the gw_full_latest folder on your Raspberry, in a folder named lora_gateway or, (iii) get only (svn checkout) the gw_full_latest folder in a folder named lora_gateway. Option (i) is preferable and is basically an automatization of option (iii), however it needs Internet connectivity on the gateway.

First option
------------

If your gateway has Internet connectivity (DHCP with Internet sharing for instance), you can use our update_gw.sh script. Even if the SD card image has a recent version of the gateway software the update_gw.sh script in the lora_gateway/scripts folder it is safer to get the latest version of this script. Simply do:

	> cd /home/pi
	> wget https://raw.githubusercontent.com/CongducPham/LowCostLoRaGw/master/gw_full_latest/scripts/update_gw.sh
	> chmod +x update_gw.sh
	> ./update_gw.sh
	
Note that if you have customized configuration files (i.e. key_*, gateway_conf.json, clouds.json and radio.makefile) in the existing /home/pi/lora_gateway folder, then update_gw.sh will preserve all these configuration files. As the repository does not have a gateway_id.txt file, it will also preserve your gateway id.

Otherwise, if it is really the first time you install the gateway, then you can delete the lora_gateway folder before running the script:

	> rm -rf lora_gateway
	> ./update_gw.sh

Second option
-------------

This upgrade solution can be done on the Raspberry if it has Internet connectivity or on your laptop which is assumed to have Internet connectivity. If you don't have git installed on your laptop, you have to install it first. Then get all the repository:

	> cd /home/pi
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
	
If you download the repository from your laptop, then rename gw_full_latest into lora_gateway and copy the entire lora_gateway folder into the Raspberry using scp for instance. In the example below, the laptop has wired Internet connectivity and use the gateway's advertised WiFi to connect to the gateway. Therefore the IP address of the gateway is 192.168.200.1.

	> scp -r lora_gateway pi@192.168.200.1:/home/pi
	
If you don't want to use/install git, use your laptop to get the .zip file of the [entire github](https://github.com/Waziup/waziup-gateway) with the "Clone or download", unzip the package, rename the gw_full_latest folder as lora_gateway and perform the scp command.		  

Third option
------------

This upgrade solution can be done on the Raspberry if it has Internet connectivity or on your laptop which is assumed to have Internet connectivity. If you don't have svn installed on your laptop, you have to install it first. Then get only the gateway part:

	> cd /home/pi
	> svn checkout https://github.com/Waziup/waziup-gateway/trunk/gw_full_latest lora_gateway
	
That will create the lora_gateway folder and get all the file of (GitHub) waziup-gateway/gw_full_latest in it.
	
To install svn on the Raspberry:

	> sudo apt-get install subversion	
	
Here, again, you can do all these steps on your laptop and then use scp to copy to the Raspberry.	

Configuring your gateway after update
-------------------------------------

After gateway update, you need to configure your new gateway with basic_config_gw.sh, that mainly assigns the gateway id so that it is uniquely identified (the gateway's WiFi access point SSID is based on that gateway id for instance). The gateway id will be the last 5 bytes of the Rapberry eth0 MAC address (or wlan0 on an RPI0W without Ethernet adapter) and the configuration script will extract this information for you. There is an additional script called test_gwid.sh in the script folder to test whether the gateway id can be easily determined. In the script folder, simply run test_gwid.sh:

	> cd /home/pi/lora_gateway/scripts
	> ./test_gwid.sh
	Detecting gw id as 00000027EBBEDA21
	
If you don't see something similar to 00000027EBBEDA21 (8 bytes in hex format) then you have to explicitly provide the **last 5 bytes**	of the gw id to basic_config_gw.sh. Otherwise, in the script folder, simply run basic_config_gw.sh to automatically configure your gateway. 

	> cd /home/pi/lora_gateway/scripts
	> ./basic_config_gw.sh
	
or

	> ./basic_config_gw.sh 27EBBEDA21

If you need more advanced configuration, then run config_gw.sh as described [here](https://github.com/CongducPham/LowCostLoRaGw/blob/master/gw_full_latest/README.md#configure-your-gateway-with-config_gwsh). However, basic_config_gw.sh should be sufficient for most of the cases. The script also compile the gateway program. After configuration, reboot your Raspberry. 

By default gateway_conf.json configures the gateway with a simple behavior: LoRa mode 1 (BW125SF12), no DHT sensor in gateway (so no MongoDB for DHT sensor), no downlink, no AES, no raw mode. clouds.json enables only the ThingSpeak demo channel (even the local MongoDB storage is disabled). You can customize your gateway later when you have more cloud accounts and when you know better what features you want to enable.

The LoRa gateway starts automatically when RPI is powered on. Then use cmd.sh to execute the main operations on the gateway as described in [here](https://github.com/CongducPham/LowCostLoRaGw/blob/master/gw_full_latest/README.md#use-cmdsh-to-interact-with-the-gateway).			

