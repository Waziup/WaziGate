import * as React from "react";
import * as API from "../../api";

import {
	// MDBBtn,
	MDBCard,
	MDBCardBody,
	MDBCardTitle,
	// MDBCardText,
	MDBAlert,
	MDBIcon
} from "mdbreact";

import LoadingSpinner from "../LoadingSpinner";
// import LoadingSpinner from "../LoadingSpinner";

declare function Notify(msg: string): any;

export interface Props {
	name: string;
	desc?: string;
	icon?: string;
}
export interface State {
	loading: boolean;
	data: any;
}

class SensorItem extends React.Component<Props, State> {
	constructor(props: Props) {
		super(props);

		this.state = {
			loading: true,
			data: null
		};
	}

	/**------------- */

	_isMounted = false;
	componentDidMount() {
		this._isMounted = true;
		this.loopLoad();
	}
	componentWillUnmount() {
		this._isMounted = false;
	}
	/**------------- */

	/**------------- */

	loopLoad() {
		if (!this._isMounted) return;

		this.setState({ loading: true });
		API.getSensorValue(this.props.name).then(
			res => {
				this.setState({
					data: res,
					loading: false
				});
				setTimeout(() => {
					this.loopLoad();
				}, 15000); // Check every 15 seconds
			},
			error => {
				Notify(error);
				this.setState({ loading: false });
			}
		);
	}

	/**------------- */

	render() {
		if (this.state.data === null) {
			// return <MDBIcon icon="cog" size="2x" spin />;
			return <LoadingSpinner type="grow" class="mt-5" />;
		}

		var data = [];
		for (var i in this.state.data) {
			data.push({ key: i, value: this.state.data[i] });
		}

		var listOfValues = data.map((res: any, index: React.ReactText) => (
			<MDBAlert key={index} color="info">
				<span className="text-capitalize">
					{res.key} : <b>{res.value}</b>
				</span>
			</MDBAlert>
		));

		return (
			<MDBCard
				className="mt-3 m-l3"
				//  style={{ width: "32rem" }}
			>
				<MDBCardBody>
					<MDBCardTitle title={"Sensor: " + this.props.name}>
						<MDBIcon
							spin={this.state.loading}
							icon={
								this.state.loading
									? "cog"
									: this.props.icon
									? this.props.icon
									: "wave-square"
							}
						/>{" "}
						{this.props.desc ? this.props.desc : this.props.name}
					</MDBCardTitle>
					{listOfValues}

					{/* <MDBBtn
						disabled={isRunning}
						title="Start"
						onClick={() => this.setContainerAction("start")}
					>
						<MDBIcon
							icon={this.state.setStartLoading ? "cog" : "play"}
							spin={this.state.setStartLoading}
						/>
					</MDBBtn> */}
				</MDBCardBody>
			</MDBCard>
		);
	}
}

export default SensorItem;
