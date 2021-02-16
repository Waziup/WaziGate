# Generating ISO file for WaziGate

To generate an ISO file, the follwoin steps need to be taken:

## Flash the PI with Raspbian

 First flash your Raspberry pi with the latest working Raspbian. 
 
 1. Download and install Etcher tool on your PC from here: https://www.balena.io/etcher/
 2. Download the latest Raspbian: https://www.raspberrypi.org/downloads/raspbian/
 3. Flash the SD card with Raspbian
 4. After that, you need to mount the SD card on you PC (if it's not already mounted somewhere), and create a file named **ssh** without extention on the SD card.
If it has multiple partitions, just create it on anyone you are allowed to (usually named `boot`).

```
mount
cd <mount path>
touch ssh
```
5. Connect the RPI to your PC or your router by an Ethernet cable.
6. You can now remove the SD card from your PC and insert it into the Raspberry PI and turn on the PI.

## Install the production version of WaziGate

To install the production version of the Wazigate firmware on Raspbian please follow these steps:

1. Let the PI boots up and then find the IP address of the pi via `Angry IP scanner` or `nmap`. The tutorial is shown in this video: https://youtu.be/DvGdmdsGZHA?t=360

Note: if you have only one Raspberry PI running Raspbia in your network, there is a chance that `raspberrypi.local` works instead of the IP address.

2.Open a terminal and ssh into the PI. Password is `raspberry`:

```
ssh pi@<PI_IP_Address>
```
or 
```
ssh pi@raspberrypi.local
```

3. Then download and install WaziGate with the following command on the RPI terminal:
```
curl -fsSL https://raw.githubusercontent.com/Waziup/WaziGate/master/setup/get_waziup_test.sh | bash
```

This will take a while. Time to grab a cup of tea.
Once finished, the pi will be rebooted and then pulls the containers and set up everything, then reboots again.
Then you can access your Wazigate UI on http://wazigate.local/ !

The password will be changed to `loragateway`

## Generating the ISO

1. The first step to generate ISO is to test your Wazigate and make sure everything works well.
2. Then you need to prepare the PI by running the following commands:

```
cd /home/pi/waziup-gateway/setup/
sudo apt-get install -y samba nano
git clone https://github.com/scruss/RonR-RaspberryPi-image-utils.git image-utils
cd image-utils
sudo chmod +x *
sudo mkdir /media/remote
sudo chown -R pi:pi /media/remote
```
3. You need to create a shared folder (on linux use samba) on your machine where the ISO image will be stored in. Please set the name of the shared folder as `share`.

4. Then you need to do the followin modification:
```
cd /home/pi/waziup-gateway/setup/
nano sd-card-image.sh
```
Find this line:
`sudo mount -t cifs //10.42.0.1/share /media/remote -o username=gholi`

and update it with the ip address of your machine (`10.42.0.1`) and if applicable give your username instead of `gholi`

Then save and exit.
5. Run the followin command on the PI:
```
cd /home/pi/waziup-gateway/setup/
sudo ./sd-card-image.sh
```

It asks you couple of questions and then start making ISO.

**Important Notes:**
- Please note that it cleans up the PI before generating the ISO file. It removes databases, config files, etc. If you develop the project further, you need to add/modify the cleanup instructions in the `sd-card-image.sh` file.
- When it asks you about the size of the image, if you want your image to be flashable on an 8GB SD Card, use 7000 (in MB) as it is not very accurate in size.
- If it fails building image, try it again. Sometimes it fails to mount the directory on the PI and you need to reboot the PI.
- Once it builds and image successfully, the next time for the same Wazigate with some modifications, you do not need to build it from scrach, it updates it as long as the ISO file is in the same path i.e. `wazigate.img`
