import * as React from "react";
import * as API from "../../../api";
import ErrorComp from "../../Error";

import {
  MDBContainer,
  MDBTabPane,
  MDBTabContent,
  MDBNav,
  MDBNavItem,
  MDBNavLink,
  MDBIcon,
  MDBListGroup,
  MDBAlert,
} from "mdbreact";
import LoadingSpinner from "../../LoadingSpinner";
import WiFiScanItem from "./WiFiScanItem";

declare function Notify(msg: string): any;

export interface Props {}
export interface State {
  WiFiScanResults: API.WiFiScan[];
  WiFiInfo: API.WiFiInfo;
  error: any;
  scanLoading: boolean;
  activeItem: any;
}

class PagesInternet extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      WiFiScanResults: null,
      WiFiInfo: null,
      error: null,
      scanLoading: true,
      activeItem: "wifi",
    };
  }

  /**------------- */
  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
    this.scan();
    // if( !this._isMounted) return;
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  scan() {
    if (!this._isMounted) return;
    if (this.state.activeItem != "wifi") return;

    this.updateWiFiInfo();

    this.setState({
      scanLoading: true,
    });

    API.getWiFiScan().then(
      (WiFiScanResults) => {
        if (WiFiScanResults.length) {
          let uniqueList = [];
          let tmpArr = Array();

          for (var i = 0; i < WiFiScanResults.length; i++) {
            if (tmpArr.indexOf(WiFiScanResults[i].name) == -1) {
              uniqueList.push(WiFiScanResults[i]);
              tmpArr.push(WiFiScanResults[i].name);
            }
          }

          this.setState({
            WiFiScanResults: uniqueList,
          });
        }

        this.setState({
          scanLoading: false,
          error: null,
        });

        setTimeout(() => {
          this.scan();
        }, 5000); // 5 seconds
      },
      (error) => {
        this.setState({
          scanLoading: false,
          error: error,
        });

        setTimeout(() => {
          this.scan();
        }, 5000); // 5 seconds
      }
    );
  }

  /**------------- */

  toggle = (tab: any) => () => {
    if (this.state.activeItem !== tab) {
      this.setState({
        activeItem: tab,
      });

      if (tab == "wifi") {
        this.scan();
      }
    }
  };

  /**------------- */

  updateWiFiInfo() {
    API.getWiFiInfo().then(
      (WiFiInfo) => {
        // console.log(WiFiInfo);
        this.setState({
          WiFiInfo: WiFiInfo,
          error: null,
        });
      },
      (error) => {
        this.setState({
          WiFiInfo: null,
          error: error,
        });
      }
    );
  }

  /**------------- */

  render() {
    if (this.state.error) {
      return <ErrorComp error={this.state.error} />;
    }

    var scanResult = this.state.WiFiScanResults
      ? this.state.WiFiScanResults.map((res) => (
          <WiFiScanItem
            name={res.name}
            key={res.name}
            signal={res.signal}
            active={this.state.WiFiInfo && res.name == this.state.WiFiInfo.ssid}
          />
        ))
      : "";

    // console.log(scanResult);

    var wifiStatus = null;
    if (this.state.WiFiInfo) {
      if (this.state.WiFiInfo.ap_mode) {
        wifiStatus = (
          <span>
            {" "}
            Mode: <b>Access Point</b> <MDBIcon icon="broadcast-tower" /> 
            <div className="float-right"> SSID:{" "}
            <b>
              {this.state.WiFiInfo.ssid ? (
                this.state.WiFiInfo.ssid
              ) : (
                <MDBIcon icon="spinner" spin />
              )}
            </b>
            </div>
          </span>
        );
      } else {
        wifiStatus = (
          <span>
            {" "}
            Mode: <b>WiFi client</b> <MDBIcon icon="wifi" />
            
            <div className="float-right"> Network: {" "}
            <b>
              {this.state.WiFiInfo.ssid ? (
                this.state.WiFiInfo.ssid
              ) : (
                <MDBIcon icon="spinner" spin />
              )}
            </b>{" "}
            (
            {this.state.WiFiInfo.ip ? (
              this.state.WiFiInfo.ip
            ) : (
              <MDBIcon icon="spinner" spin />
            )}
            ){"  "}
            <span title={this.state.WiFiInfo.state}>
              {this.state.WiFiInfo.state ? (
                this.state.WiFiInfo.state == "COMPLETED" ? (
                  <MDBIcon fas icon="check-circle" />
                ) : (
                  <span>
                    <MDBIcon icon="spinner" spin /> {this.state.WiFiInfo.state}
                  </span>
                )
              ) : (
                "..."
              )}
            </span>
            </div>
          </span>
        );
      }
    }

    //nav-justified

    return (
      <MDBContainer className="mt-3">
        <MDBNav tabs className="nav md-pills nav-pills ">
          <MDBNavItem>
            <MDBNavLink
              to="#"
              active={this.state.activeItem === "wifi"}
              onClick={this.toggle("wifi")}
              role="tab"
              // className="bg-info"
              activeClassName="active-link"
            >
              <MDBIcon icon="wifi" /> WiFi
            </MDBNavLink>
          </MDBNavItem>
          {/* <MDBNavItem>
						<MDBNavLink
							to="#"
							active={this.state.activeItem === "2"}
							onClick={this.toggle("2")}
							role="tab"
						>
							<MDBIcon icon="signal" /> LTE
						</MDBNavLink>
					</MDBNavItem>
					<MDBNavItem>
						<MDBNavLink
							to="#"
							active={this.state.activeItem === "3"}
							onClick={this.toggle("3")}
							role="tab"
						>
							<MDBIcon icon="envelope" /> Contact
						</MDBNavLink>
					</MDBNavItem> */}
        </MDBNav>
        <MDBTabContent className="card p-2" activeItem={this.state.activeItem}>
          <MDBTabPane tabId="wifi" role="tabpanel">
            <MDBAlert color="info" className="text-justify">
              {wifiStatus ? (
                wifiStatus
              ) : (
                <span>
                  Loading <MDBIcon icon="spinner" spin />{" "}
                </span>
              )}
            </MDBAlert>

            <MDBAlert color="light">
              Please select a network:
            </MDBAlert>

            <MDBListGroup>
              {scanResult}
              <WiFiScanItem name="Connect to a hidden WiFi" empty signal="0" />
            </MDBListGroup>
            <MDBAlert color="light">
              {this.state.scanLoading ? (
                <div style={{textAlign: "center"}} >Checking for avilable networks <LoadingSpinner
                  type="grow-sm"
                  class="color-light-text-primary"
                /></div> 
              ) : (
                ""
              )}
            </MDBAlert>
          </MDBTabPane>

          {/* <MDBTabPane tabId="2" role="tabpanel">
						<p className="mt-2"></p>
					</MDBTabPane>
					<MDBTabPane tabId="3" role="tabpanel">
						<p className="mt-2"></p>
					</MDBTabPane> */}
        </MDBTabContent>
      </MDBContainer>
    );
  }
}

export default PagesInternet;
