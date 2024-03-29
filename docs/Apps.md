WaziApps
========

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

