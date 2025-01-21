WaziGate developpers documentation
=================================

This folder contains implementation details about the WaziGate software for developpers.
User documentation can be found in the [Waziup website](http://www.waziup.io).

The WaziGate is realized in containerized components written mainly in Go language.
The containers are running in a Docker platform directly on the Raspberry PI.
All the components and kept in separate GitHub repositories.
The various components are integrated together in the main GitHub repository (this repository), using git “submodules” feature.

- ISO image creation
- Raspberry PI system management
- LoRaWAN management
- WaziGate apps


Generating ISO file for WaziGate
-------------------------------


To generate an ISO file, the follwoin steps need to be taken:

### Flash the PI with Raspbian

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

### Install the production version of WaziGate

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

### Generating the ISO

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


Wazigate System
---------------

_This document explains how the wazigate system works in the WaziGate firmware to used for further development._

The management of the Raspberry PI system (such as ON/OFF, Wifi, OLED...) is managemed by a container called wazigate-system.
The first code that is executed by the container is located in `/api/init.go`. It sets some configurations like logs and default network devices.
Then it runs a number of `Go routines` listed below:

- TimezoneInit()
- BlackoutLoop()
-	NetworkLoop()
-	ButtonsLoop()
-	OledLoop()
-	FanLoop()

Each of these routins take care of one part in parallel with others.
Then in the `main.go` file, the main fucntion is executed which initiates the HTTP API service over a Unix socket.
The user interface of `wazigate-system` is located in the `ui` folder. It is implemented with `REACT.js`.

All APIs source code are located in the `api` directory.

The file `/api/time.go` containes a number of functions that handle timezone of the gateway. By default it sets the timezone to `auto` which then it calls `func getIPBasedTimezone() (string, error)` function to get the timezone based on the public IP address of the gateway. The public IP address of the gateway is detemined through this online service: `http://ip-api.com/json/`

On modern `WaziHAT Pro Multi` there is a blackout protection circuit that holds energy for about 20 seconds after blackout and signals the PI thourgh `GPIO23` if that happens.
The file `/api/blackout.go` has a fucntion called `func BlackoutLoop()` which constnantly monitors `GPIO23` and if this GPIO goes from `HIGH` to `LOW` that means the main power is out and it then immediately shuts down the gateway in order to avoid any damage caused by blackout.

- Once it builds and image successfully, the next time for the same Wazigate with some modifications, you do not need to build it from scrach, it updates it as long as the ISO file is in the same path i.e. `wazigate.img`


WaziApps
--------

**Note:** If you wanna learn how to develop and App for WaziGate please head over to the free online course that specifically designed for this purpose: https://www.waziup.io/courses/waziapps/

_This document explains how the App mechanism works in the WaziGate firmware which can be used for further development._

Apps are stored in `/var/lib/wazigate/apps/<org>/<appName>` and managed by `wazigate-edge` service whose repo is here: https://github.com/Waziup/wazigate-edge/
Under the `api` folder there is a file called `apps.go` which provides a set of APIs for managing the Apps.


-----------------------------

`const dockerSocketAddress = "/var/run/docker.sock"`

Since the App manager calls some docker APIs for handling images and containers, we need to have this path and to be mapped to the container as well.

-----------------------------

```
type installingAppStatusType struct {
	id   string
	done bool
	log  string
}

var installingAppStatus []installingAppStatusType
```

While an App is being installed or updated, since those operations are done asynchronously, the UI does not have an idea how it is going. So, we use this struct to keep the user updated about the progress and status.

-----------------------------

`func GetApps(resp http.ResponseWriter, req *http.Request, params routing.Params)`

Implements `GET /apps` list the Apps if the parameter `available` is set, it returns a list of available Apps for installation otherwise it returns the installed Apps in JSON format.

-----------------------------

`func GetApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`

Returns the App info by calling some Docker APIs and reading the `package.json` file in the App folder.
If this function is called with `install_logs` parameter, it returns the status of the App if it is being installed or updated.

-----------------------------

`func PostApps(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function handles the installation of an App. It receives a docker image name and then calls `installApp(imageName)` function which downloads the image from docker hub and installs it on the pi.

-----------------------------

`func installApp(imageName string) (string, error)`

This function performs the App installation. It downloads the given image from the docker hub, then creates a temporary container in order to extract `index.zip` file which holds all the config and docker-compose files. The temporary container will be deleted afterwards. It then pulls all the dependency images indicated in the `docker-compose.yml` file using `docker-compose` tool.

-----------------------------

`func PostApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function updates the status of a given App (docker container). Stop, Start, and first-start (pulling images if needed) of an App and also sets Restart policy for each App.

-----------------------------

`func DeleteApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function uninstalls an App. It receives the `appID` and `keepConfig` as parameters and removes the containers, images and if `keepConfig` is set to `false`, it removes the associated volumes and config files, basically wipes everything.

-----------------------------

`func HandleAppProxyRequest(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function bridges `unix sockets` that uses by Apps to `HTTP` protocol via `wazigate-edge`. In other words, it routs all the requests for a specific App going through the `wazigate-edge` container to the targeted App.

-----------------------------

`func handleAppProxyError(appID string, moreInfo string) string`

This function generates an `HTML` content for error handling of the `Proxy` function.

-----------------------------

`func GetUpdateApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function receives an appID and determines whether the App has new updates available or not. It checks the digest of all images of the App in docker hub and if it observes any difference, it concludes that there is a new update for the App. Obviously, the App developers must keep the tags of their images intact for this function to work properly.

-----------------------------

`func getAppImages(appID string) ([]string, error)`

This function receives an appD, find all its images and returns a list of them. It parses the `docker-compose.yml` file of the targeted App.

-----------------------------

`func dockerHubAccessible() bool`

This function checks if the docker hub is accessible via internet or not.

-----------------------------

`func PostUpdateApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`

Ths function receives an `appID` and updates it by pulling the latest images from docker hub and replace with the current one (uninstall the current version and install a new one ;])
Please note that it will replace `docker-compose.yml` and `package.json` files with the new version as well. If the App developer want to make sure not to replace a config file mapped to the root of the App i.e. `~/waziup-gateway/apps/<org>/<appName>`, they need to handle it themselves.

-----------------------------

`func updateEdge() error`

This function updates the `wazigate-edge` itself and it is called by `PostUpdateApp`.

-----------------------------

`func uninstallApp(appID string, keepConfig bool) error`

This function removes an App and it is called by `DeleteApp` function.

