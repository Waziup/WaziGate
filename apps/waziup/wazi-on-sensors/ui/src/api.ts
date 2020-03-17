// This is how to run it on your PC
// chromium-browser --disable-web-security --user-data-dir="./tmp"

// const URL = "http://192.168.0.104:5300/";
const URL = "../";

async function failResp(resp: Response) {
	var text = await resp.text();
	throw `There was an error calling the API.\nThe server returned (${resp.status}) ${resp.statusText}.\n\n${text}`;
}

/*--------------*/

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
