import * as React from "react";
import * as API from "../api";

import PagesOverview from "./Pages/Overview";

import "../style/app.scss";
import "@fortawesome/fontawesome-free/css/all.min.css";
import "bootstrap-css-only/css/bootstrap.min.css";
import "mdbreact/dist/css/mdb.css";
import Notifications from "./Notifications";

export interface AppCompState {
	pageComp: JSX.Element;
}

export interface AppCompProps {
	hideLoader: Function;
	showLoader: Function;
}

class AppComp extends React.Component<AppCompProps, AppCompState> {
	constructor(props: AppCompProps) {
		super(props);
	}

	/*---------*/

	componentDidMount() {
		this.props.hideLoader();
	}

	/*---------*/

	render() {
		return <PagesOverview />;
	}
}

export default AppComp;
