import * as React from "react";
import * as API from "../../api";
import ErrorComp from "../Error";

import {
	MDBContainer,
	MDBTabPane,
	MDBTabContent,
	MDBNav,
	MDBNavItem,
	MDBNavLink,
	MDBIcon,
	MDBBtn,
	MDBAlert
} from "mdbreact";
import LoadingSpinner from "../LoadingSpinner";

declare function Notify(msg: string): any;

export interface Props {}
export interface State {
	data: any;
	error: any;
	updateLoading: boolean;
	activeItem: any;
	version: any;
}

class PagesInternet extends React.Component<Props, State> {
	constructor(props: Props) {
		super(props);
		this.state = {
			data: "",
			error: null,
			version: null,
			updateLoading: false,
			activeItem: "full"
		};
	}

	_isMounted = false;
	componentDidMount() {
		this._isMounted = true;
		this.loopLoad();
		this.getVersion();
	}
	componentWillUnmount() {
		this._isMounted = false;
	}
	/**------------- */

	loopLoad() {
		if (!this._isMounted) return;

		API.getUpdateStatus().then(
			res => {
				this.setState({
					data: res
				});
				setTimeout(() => {
					this.loopLoad();
				}, 1000); // Check every second
			},
			error => {
				Notify(error);
				setTimeout(() => {
					this.loopLoad();
				}, 1000); // Check every second
			}
		);
	}

	/**------------- */

	getVersion() {
		this.setState({
			version: null
		});
		API.getVersion().then(
			res => {
				this.setState({
					version: res
				});
			},
			error => {
				Notify(error);
			}
		);
	}

	/**------------- */

	doFullUpdate() {
		this.setState({
			updateLoading: true
		});
		API.doUpdate().then(
			res => {
				this.setState({
					updateLoading: false
				});
				this.getVersion();
				Notify(res);
			},
			error => {
				Notify(error);
			}
		);
	}

	/**------------- */

	toggle = (tab: any) => () => {
		if (this.state.activeItem !== tab) {
			this.setState({
				activeItem: tab
			});
		}
	};

	/**------------- */

	render() {
		if (this.state.error) {
			return <ErrorComp error={this.state.error} />;
		}

		return (
			<MDBContainer className="mt-3">
				<MDBNav tabs className="nav md-pills nav-pills nav-justified">
					<MDBNavItem>
						<MDBNavLink
							to="#"
							active={this.state.activeItem === "full"}
							onClick={this.toggle("full")}
							role="tab"
							// className="bg-info"
							activeClassName="active-link"
						>
							<MDBIcon icon="sync-alt" /> Full Update
						</MDBNavLink>
					</MDBNavItem>
				</MDBNav>
				<MDBTabContent className="card p-2" activeItem={this.state.activeItem}>
					<MDBTabPane tabId="full" role="tabpanel">
						<MDBAlert color="info" className="text-justify">
							Current version:{" "}
							<b>
								{this.state.version ? (
									this.state.version
								) : (
									<span>
										<MDBIcon icon="spinner" spin />{" "}
									</span>
								)}
							</b>
						</MDBAlert>

						<MDBBtn
							onClick={() => this.doFullUpdate()}
							disabled={this.state.updateLoading}
						>
							<MDBIcon icon="redo-alt" />
							{"  "}
							Run a Full Update
						</MDBBtn>

						<div
							className="content-center mt-2"
							style={{ margin: "auto 30%", height: "18px" }}
						>
							{this.state.updateLoading ? (
								<LoadingSpinner
									type="progress"
									class="color-light-text-primary"
								/>
							) : (
								""
							)}
						</div>

						<textarea
							rows={18}
							className="bg-dark text-light form-control form-rounded"
							readOnly={true}
							value={this.state.data}
							style={{ display: this.state.data == "" ? "none" : "" }}
						></textarea>
					</MDBTabPane>
				</MDBTabContent>
			</MDBContainer>
		);
	}
}

export default PagesInternet;
