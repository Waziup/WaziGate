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

```
type installingAppStatusType struct {
	id   string
	done bool
	log  string
}

var installingAppStatus []installingAppStatusType
```

While an App is being installed or updated, since those opperations are done asyncronousely, the UI does not have an idea how it is going. So, we use this struct to keep the user updated about the progress and status.

-----------------------------

`func GetApps(resp http.ResponseWriter, req *http.Request, params routing.Params)`
Implements `GET /apps` list the Apps if the parameter `available` is set, it returns a list of available Apps for installation otherwize it returns the installed Apps in JSON format.

-----------------------------

`func GetApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`
Returns the App info by calling some Docker APIs and reading the `package.json` file in the App folder.
If this function is called with `install_logs` parameter, it returns the status of the App if it is being installed or updated.

-----------------------------

`func PostApps(resp http.ResponseWriter, req *http.Request, params routing.Params)`
This function handles the installation of an App



-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
-----------------------------
