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

