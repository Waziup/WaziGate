V3.1.0
------
* Added VPN support for resilient remote access — the gateway dials home over OpenVPN via
  NetworkManager, with autoconnect retries and keepalive so the tunnel survives flaky links
* VPN can now be configured from the dashboard: connection options, live status, a direct
  gateway link, and a hint when the gateway is not yet registered to WaziCloud
* Major network traffic reduction — cloud health check went from every 3 s to every 5 min and
  all network polling was unified, cutting cellular data usage substantially
+ Added support for UPS module, makes gateway more resilient agains
* Added automatic token refresh in the dashboard, so long sessions no longer drop to the login screen
* MQTT broker and REST API addresses are now editable in the settings
* Fixed LoRa downlink payload handling and the downlink queue
* Hardened system reporting — safer memory and disk usage parsing, retry logic when fetching the
  gateway ID, and log files created before first write
* All services now restart automatically after a Docker crash or reboot
* Updated base images to Debian trixie / Ubuntu 22.04 following the buster archival
* Faster builds via Go module and build caching, with the toolchain pinned to golang 1.26.6
* Removed redundant Swagger and gateway API endpoints; VPN routes are now documented


V3.0.1
------
Bug fixes:
  - WaziGate LoRa v3- Chirpstack API token not refreshing (PLAT-3642)
  - WaziGate: actuation downlink is received as string instead of XLPP (PLAT-3872)

V3.0.0
------

  - New dashboard UI
  - Updated ChirpStack to v4

V2.3.2
------

  - Integrated SSH terminal to UI for remote maintenance
  - Introduced function to export gateways data in different manners 
  - Set clock and timezone automatically
  - Compression of resources to support slow networks

V2.3.0
------

- Memory performance improvement: 10 time less SD card writes
- CPU Performance improvement 
- New app management feature
- Better Wifi support
- Display of sensor historical values
- Transition to 64 bits architecture

V2.2.0
------

- First Debian release of WaziGate

V1.1.1
------
Bug fixes: 
- https://github.com/Waziup/WaziGate/issues/72
- https://github.com/Waziup/WaziGate/issues/73

V1.1
----
New features:
- new wazigate-lora in Go language
- HDMI screen direct connection

Bug fixes: 
- https://github.com/Waziup/WaziGate/issues/61
- https://github.com/Waziup/WaziGate/issues/54
- Performance improvements

V1.0
----

- Wifi Hotspot
- Wifi client
- Ethernet cable access
- Setup Wizard
- login management
- Cloud registration
- Remote configuration from Cloud dashboard
- LoRa devices and sensors registration and streaming
- OLED display
- Edge devices and data management
