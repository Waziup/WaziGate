import * as React from "react";
import { Component } from "react";
import * as API from "../../api";
import ErrorComp from "../Error";

import { MDBContainer, MDBRow, MDBCol } from "mdbreact";

import SensorItem from "./SensorItem";

export interface Props {}
export interface State {
	allSensors: any;
	error: any;
}

class PagesOverview extends React.Component<Props, State> {
	constructor(props: Props) {
		super(props);
		this.state = {
			allSensors: null,
			error: null
		};
	}

	/**------------- */
	_isMounted = false;
	componentDidMount() {
		this._isMounted = true;

		API.getAllSensors().then(
			res => {
				this.setState({
					allSensors: res,
					error: null
				});
			},
			error => {
				this.setState({
					allSensors: null,
					error: error
				});
			}
		);

		// if( !this._isMounted) return;
	}
	componentWillUnmount() {
		this._isMounted = false;
	}
	/**------------- */

	render() {
		if (this.state.error) {
			return <ErrorComp error={this.state.error} />;
		}

		var sensors = this.state.allSensors
			? this.state.allSensors.map((res: any, index: React.ReactText) => (
					<SensorItem
						key={index}
						name={res.name}
						desc={res.desc}
						icon={res.name == "si7021" ? "temperature-low" : ""}
					/>
			  ))
			: "";

		return (
			<MDBContainer>
				<MDBRow>
					<MDBCol> {sensors}</MDBCol>
				</MDBRow>
			</MDBContainer>
		);
	}
}

export default PagesOverview;
