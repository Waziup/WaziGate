import * as React from "react";
import { Component } from "react";
import { MDBProgress } from "mdbreact";

export interface Props {
	type?: string;
	class?: string;
}
export interface State {}

class LoadingSpinner extends React.Component<Props, State> {
	constructor(props: Props) {
		super(props);
	}

	/**------------- */

	render() {
		switch (this.props.type) {
			case "small":
				return (
					<div
						className={"spinner-border spinner-border-sm " + this.props.class}
						role="status"
					>
						<span className="sr-only">Loading...</span>
					</div>
				);

			case "grow":
				return (
					<div className={"spinner-grow " + this.props.class} role="status">
						<span className="sr-only">Loading...</span>
					</div>
				);

			case "grow-sm":
				return (
					<div
						className={"spinner-grow spinner-grow-sm " + this.props.class}
						role="status"
					>
						<span className="sr-only">Loading...</span>
					</div>
				);

			case "fast":
				return (
					<div
						className={"spinner-border fast " + this.props.class}
						role="status"
					>
						<span className="sr-only">Loading...</span>
					</div>
				);
			case "progress":
				return (
					<MDBProgress
						color="info"
						barClassName={this.props.class}
						material
						animated
						value={100}
					/>
				);
		}

		return (
			<div className={"lds-ripple " + this.props.class}>
				<div></div>
				<div></div>
			</div>
		);
	}
}

export default LoadingSpinner;
