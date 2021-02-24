Wazigate System
===============

_This document explains how the wazigate system works in the WaziGate firmware to used for further development._

The first code that is executable by the system is located in `/api/init.go` which sets some configurations like logs and default network devices. Then it runs a number of `Go routins` listed below:

- TimezoneInit()
- BlackoutLoop()
-	NetworkLoop()
-	ButtonsLoop()
-	OledLoop()
-	FanLoop()

Each of these routins take care of one part simultaniosly with others.

Then in the `main.go` file, the main fucntion is executed which initiates the HTTP API service over a Unix socket.

The user interface of `wazigate-system` is located in the `ui` folder. It is implemented with `REACT.js`.

All APIs source code are located in the `api` directory.

### `/api/time.go`
This file containes a number of functions that handle timezone of the gateway. By default it sets the timezone to `auto` which then it calls `func getIPBasedTimezone() (string, error)` function to get the timezone based on the public IP address of the gateway. The public IP address of the gateway is detemined through this online service: `http://ip-api.com/json/`

