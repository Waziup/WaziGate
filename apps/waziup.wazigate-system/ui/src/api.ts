// This is how to run it on your PC
// chromium-browser --disable-web-security --user-data-dir="./tmp"

// const URL = "http://10.42.0.33:5000/";
const URL = "../";

async function failResp(resp: Response) {
  var text = await resp.text();
  throw `There was an error calling the API.\nThe server returned (${resp.status}) ${resp.statusText}.\n\n${text}`;
}

/*--------------*/

export async function internet() {
  /*	console.log("Call internet");
	return await fetch(URL + "internet")
		.then(response => {
			if (response.ok) {
				return response.json();
			} else {
				throw "Something went wrong";
				// throw new Error("Something went wrong");
			}
		})
		.then(responseJson => {
			// Do something with the response
			return responseJson;
		})
		.catch(error => {
			console.log(error);
		});

		*/
  var resp = await fetch(URL + "internet");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}
/*--------------*/

export async function getTime() {
  var resp = await fetch(URL + "time");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*-------------- */

export async function getTimezones() {
  var resp = await fetch(URL + "timezones");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function getTimezone() {
  var resp = await fetch(URL + "timezone");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function getTimezoneAuto() {
  var resp = await fetch(URL + "timezone/auto");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function setTimezone(data: string) {
  var resp = await fetch(URL + "timezone", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });
  if (!resp.ok) await failResp(resp);
  return await resp.text();
  // return await resp.json();
}

/*-------------- */

export type NetInfo = {
  ip: string;
  dev: string;
  mac: string;
};

export async function getNetInfo(): Promise<NetInfo> {
  var resp = await fetch(URL + "net");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export type APInfo = {
  SSID: string;
  available: boolean;
  device: string;
  ip: string;
  password: string;
};

export async function getAPInfo(): Promise<APInfo> {
  var resp = await fetch(URL + "net/wifi/ap");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function setAPInfo(data: any) {
  var resp = await fetch(URL + "net/wifi/ap", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export async function setAPMode() {
  var resp = await fetch(URL + "net/wifi/mode/ap", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
  });
  //   console.log(resp);
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export type WiFiScan = {
  name: string;
  security: boolean;
  signal: string;
};

export async function getWiFiScan(): Promise<WiFiScan[]> {
  var resp = await fetch(URL + "net/wifi/scan");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function setWiFiConnect(data: any) {
  var resp = await fetch(URL + "net/wifi", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export type WiFiInfo = {
  ip: string;
  enabled: boolean;
  ap_mode: boolean;
  ssid: string;
  state: string;
};

export async function getWiFiInfo(): Promise<WiFiInfo> {
  var resp = await fetch(URL + "net/wifi");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export type UsageInfo = {
  cpu_usage: string;
  disk: {
    available: string;
    device: string;
    mountpoint: string;
    percent: string;
    size: string;
    used: string;
  };
  mem_usage: {
    total: string;
    used: string;
  };
  temp: string;
};

export async function getUsageInfo(): Promise<UsageInfo> {
  var resp = await fetch(URL + "usage");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export type cInfo = {
  Id: string;
  Names: string[];
  State: string;
  Status: string;
  Image: string;
};

export async function getAllContainers(): Promise<cInfo[]> {
  var resp = await fetch(URL + "docker");
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function getContainer(id: string): Promise<cInfo> {
  var all = await getAllContainers();
  for (var i = 0; i < all.length; i++) {
    if (all[i].Id == id) return all[i];
  }

  return null;

  /*var resp = await fetch(URL + "docker/" + id);
	if (!resp.ok) await failResp(resp);
	return await resp.json(); /**/
}

export async function setContainerAction(id: string, action: string) {
  var resp = await fetch(URL + "docker/" + id + "/" + action, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
  });
  if (!resp.ok) await failResp(resp);
  return await resp.text();
  // return await resp.json();
}

export async function getContainerLogs(id: string, tail: number) {
  var resp = await fetch(URL + "docker/" + id + "/logs/" + tail.toString());

  if (!resp.ok) await failResp(resp);
  return await resp.text();
}

export async function dlContainerLogs(id: string) {
  var resp = await fetch(URL + "docker/" + id + "/logs");

  if (!resp.ok) await failResp(resp);
  return resp;
}

/*---------------*/

export async function doUpdate() {
  var resp = await fetch(URL + "update", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
  });
  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function getUpdateStatus() {
  var resp = await fetch(URL + "update/status");

  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function getVersion() {
  var resp = await fetch(URL + "version");

  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export async function getAllSensors() {
  var resp = await fetch(URL + "sensors");

  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function getSensorValue(name: string) {
  var resp = await fetch(URL + "sensors/" + name);

  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export async function getBlackout() {
  var resp = await fetch(URL + "blackout");

  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

/*---------------*/

export async function getConf() {
  var resp = await fetch(URL + "conf");

  if (!resp.ok) await failResp(resp);
  return await resp.json();
}

export async function setConf(data: any) {
  var resp = await fetch(URL + "conf", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });
  if (!resp.ok) await failResp(resp);
  return await resp.text();
  // return await resp.json();
}

/*---------------*/

export async function shutdown() {
  var resp = await fetch(URL + "shutdown", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
  });
  if (!resp.ok) await failResp(resp);
  return await resp.text();
  // return await resp.json();
}

export async function reboot() {
  var resp = await fetch(URL + "reboot", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
  });
  if (!resp.ok) await failResp(resp);
  return await resp.text();
  // return await resp.json();
}

/*---------------*/
