WaziApps
========

**Note:** If you wanna learn how to develop and App for WaziGate please headover to the free online course that specificly designed for this purpose: https://www.waziup.io/courses/waziapps/

_This document explains how the App mechanism works in the WaziGate firmware which can be used for further development._

Apps are stored in `~/waziup-gateway/apps/<org>/<appName>` and managed by `wazigate-edge` service whose repo is here: https://github.com/Waziup/wazigate-edge/
Under the `api` fodler there is a file called `apps.go` which provides a set of APIs for managing the Apps.

-----------------------------

`const appsDirectoryOnHost = "../apps/"`

This constant keeps the relative path to the `apps` directory on the host. The path is relative to `~/waziup-gateway/wazigate-host/wazigate-host` which handles executing commands directly on the host.

-----------------------------

`const appsDirectoryMapped = "/root/apps"`
The apps folder is also mapped to the `wazigate-edge` container in order to make it easier and faster for some operations.

-----------------------------

`const dockerSocketAddress = "/var/run/docker.sock"`
Since the App manager calles some docker APIs for handling images and containers, we need to have this path and to be mapped to the conaienr as well.

-----------------------------

-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
