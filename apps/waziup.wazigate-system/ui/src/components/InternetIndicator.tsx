import * as React from "react";
import { Component } from "react";

import * as API from "../api";
import ErrorComp from "./Error";

import { MDBIcon } from "mdbreact";

// declare function Notify(msg: string): any;

export interface Props {
	// variant?: string;
}
export interface State {
	status: any;
	error: any;
}

class InternetIndicator extends React.Component<Props, State> {
	constructor(props: {}) {
		super(props);
		this.state = {
			status: null,
			error: null
		};
	}
	/**------------- */
	_isMounted = false;
	componentDidMount() {
		this._isMounted = true;
		this.checkTheStatus();
		// if( !this._isMounted) return;
	}
	componentWillUnmount() {
		this._isMounted = false;
	}

	/**------------- */

	checkTheStatus(oneCallOnly: any = false) {
		// console.log(oneCallOnly, "Checking net...");

		this.setState({
			status: null,
			error: null
		});

		API.internet().then(
			status => {
				this.setState({
					status: status,
					error: null
				});
				if (oneCallOnly) return;
				setTimeout(() => {
					this.checkTheStatus();
				}, 15000); // Check every 15 seconds
			},
			error => {
				console.log(error);
				this.setState({
					status: null,
					error: error
				});

				if (oneCallOnly) return;
				setTimeout(() => {
					this.checkTheStatus();
				}, 15000); // Check every 15 seconds
			}
		);
	}

	/**------------- */

	render() {
		if (this.state.error) {
			return (
				<div className="alert alert-error" style={{ margin: 0 }}>
					Error <MDBIcon icon="exclamation-triangle" />
				</div>
			);
		}

		if (this.state.status === null) {
			return (
				<div className="alert alert-primary" style={{ margin: 0 }}>
					Internet <MDBIcon icon="cog" spin />
					{/* <LoadingSpinner type="grow-sm" class="text-info ml-2 pl-1" /> */}
				</div>
			);
		}

		var className = this.state.status ? "primary" : "warning";

		return (
			<div
				className={"alert alert-" + className}
				style={{ margin: 0 }}
				onClick={() => this.checkTheStatus(true)}
			>
				Internet{" "}
				{this.state.status ? (
					<MDBIcon icon="check-circle" />
				) : (
					<MDBIcon icon="exclamation-triangle" />
				)}
			</div>
		);
	}
}

export default InternetIndicator;
