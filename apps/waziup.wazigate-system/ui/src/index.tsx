import * as React from "react";
import * as ReactDOM from "react-dom";

import { version, branch } from "./version";
import AppComp from "./components/App";

console.log("This is Wazigate-System, a %s build. %s", branch, version);

// basic UI styles, platform dependant
if (navigator.platform.indexOf("Win") == 0)
	document.body.classList.add("windows");
else if (navigator.platform.indexOf("Mac") == 0)
	document.body.classList.add("mac");
else if (navigator.platform.indexOf("Linux") != -1)
	document.body.classList.add("linux");

//React does not load the corresponding CSS, fix it later
const loader = document.querySelector(".loader");
// if you want to show the loader when React loads data again
const showLoader = () => loader.classList.remove("loader--hide");
const hideLoader = () => loader.classList.add("loader--hide");

ReactDOM.render(
	<AppComp hideLoader={hideLoader} showLoader={showLoader} />,
	document.getElementById("app")
);
