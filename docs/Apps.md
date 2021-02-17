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

This function handles the installation of an App. It receives a docker image name and then calls `installApp(imageName)` fucntion which downloads the image from docker hub and installs it on the pi.

-----------------------------

`func installApp(imageName string) (string, error)`

This fucntion performs the App installation. It downloads the given image from the docker hub, then creates a temporaty container in order to extract `index.zip` file which holds all the config and docker-compose files. The temporary container will be deleted afterwards. It then pulls all the dependency images indicated in the `docker-compose.yml` file using `docker-compose` tool running on the host via `wazigate-host` microservice.

-----------------------------

`func PostApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function updates the status of a given App (docker container). Stop, Start, and first-start (pulling images if needed) of an App and also sets Restart policy for each App.

-----------------------------

`func DeleteApp(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function uninstallas an App. It receives the `appID` and `keepConfig` as parameters and removes the containers, images and if `keepConfig` is set to `false`, it removes the associated volumes and config files, basically wipes everything.

-----------------------------

`func HandleAppProxyRequest(resp http.ResponseWriter, req *http.Request, params routing.Params)`

This function bridges `unix sockets` that uses by Apps to `HTTP` protocol via `wazigate-edge`. In other words, it routs all the requests for a specific App going through the `wazigate-edge` container to the targetted App.

-----------------------------

`func handleAppProxyError(appID string, moreInfo string) string`

This function generates an `HTML` content for error handling of the `Proxy` function.


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
-----------------------------
