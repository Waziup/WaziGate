Wazigate System
===============

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

