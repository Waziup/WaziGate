WaziGate LoRa gateway
=====================

This repo contains the source code for the Waziup Edge gateway.

** WARNING: this repo is work in progress. Do not use yet **

Quick Start
-----------

We are testing and working on an SD card image to be flashed on an SD card and your wazigate will be ready.


Install
-------

To install the Wazigate on a Raspberry pi, you need to do the following instructions:

1. First get the latest raspbian and install it on the pi: https://www.raspberrypi.org/downloads/raspbian/

**Note:** The recently released _raspbian buster_ does not support docker yet, download the [Raspbian Stretch](https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-04-09/2019-04-08-raspbian-stretch-lite.zip) instead.

2. Flash it on an SD card. You can find the instructions here: https://www.raspberrypi.org/documentation/installation/installing-images/

3. After flashing the SD card, open it on you PC and create a file named **ssh** without extention on the SD card. If it has multiple partitions, just create it on anyone you are allowed to.

4. Connect the PI with an Ethernet cable to your PC and find it's IP address. You can use either **nmap** or [Angry IP Scanner](http://angryip.org/) which is available for Windows/Mac/Linux/Android to determine the assigned IP addresses.

5. SSH into the pi. Windows users can use https://putty.org/
Usually the default credential for raspbian is:

```
- user: pi
- password: raspberry
```
**Note:** if you think this is hard to do for you, just connect a screen, keyboard and mouse to your raspberry pi and work with it just like a regular computer. The important thing is to have internet connectivity on your pi.

6. If you need to remotely manage your Wazigate, first create an account on https://remote.it/ it's free ;)
Then run the follwoing code on your raspberry pi terminal:

```
{ echo REMOTE='"email@example.com password"'; curl -fsSL https://raw.githubusercontent.com/Waziup/waziup-gateway/master/setup/get_waziup.sh ;} | bash
```
Where `email@example.com` is your user name on remote.it and `password` is your password. This script downloads and installs everything that your pi needs to turn it into a Wazigate.

7. If you don't want a remote management on your wazigate just run this code instead:

```
curl -fsSL https://raw.githubusercontent.com/Waziup/waziup-gateway/master/setup/install.sh | bash
```

This will take a while. Time to grab a cup of tea.
Once finished, the pi will be rebooted and then pulls the containers and set up everything, then reboots again.
Then you can access your Wazigate UI on http://YourPiIPAddress/

Develop
-------

Install
=======

For developer version you need to run the follwoing line if you want remote control over the gateway:

```
{ echo REMOTE='"email@example.com password"'; curl -fsSL https://raw.githubusercontent.com/Waziup/waziup-gateway/master/setup/install-dev.sh ;} | bash
```
Where `email@example.com` is your user name on remote.it and `password` is your password. This script downloads and installs everything that your pi needs to turn it into a Wazigate.

and if you don't want a remote management on your wazigate just run this code instead:

```
curl -fsSL https://raw.githubusercontent.com/Waziup/waziup-gateway/master/setup/install-dev.sh | bash
```

Please note that, since the developer version downloads the code and builds it on the pi, it usually takes longer.


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
