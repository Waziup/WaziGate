import * as React from "react";
import * as API from "../../api";
import ErrorComp from "../Error";

import Clock from "./Clock/Clock";
import TimezoneConfig from "./Clock/TimezoneConfig";

// import { Form } from "react-bootstrap";
// import { Button } from "react-bootstrap";
// import { Accordion, Card } from "react-bootstrap";
import {
  MDBContainer,
  MDBRow,
  MDBCol,
  MDBInput,
  MDBBtn,
  MDBAlert,
  MDBIcon,
} from "mdbreact";
import LoadingSpinner from "../LoadingSpinner";

declare function Notify(msg: string): any;

export interface Props {}
export interface State {
  APInfo: API.APInfo;
  setAPInfoLoading: boolean;
  switchToAPModeLoading: boolean;

  WiFiInfo: API.WiFiInfo;

  error: any;
  info: any;

  ConfInfo: any;
  setConfLoading: boolean;
}

class PagesConfig extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      APInfo: null,
      WiFiInfo: null,
      error: null,
      info: null,
      switchToAPModeLoading: false,
      setAPInfoLoading: false,

      ConfInfo: null,
      setConfLoading: false,
    };

    API.getAPInfo().then(
      (APInfo) => {
        this.setState({
          APInfo: APInfo,
          error: null,
        });
      },
      (error) => {
        this.setState({
          APInfo: null,
          error: error,
        });
      }
    );

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

    API.getConf().then(
      (res) => {
        // console.log(WiFiInfo);
        this.setState({
          ConfInfo: res,
          error: null,
        });
      },
      (error) => {
        this.setState({
          ConfInfo: null,
          error: error,
        });
      }
    );
  }

  /**------------- */
  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  /**------------- */

  submitSSID = (event: any) => {
    event.preventDefault();
    var data = {
      SSID: event.target.SSID.value,
      password: event.target.password.value,
    };

    this.setState({ setAPInfoLoading: true });

    API.setAPInfo(data).then(
      (msg) => {
        Notify(msg);
        this.setState({ setAPInfoLoading: false });
      },
      (error) => {
        Notify(error);
        this.setState({ setAPInfoLoading: false });
      }
    );
  };

  /**------------- */

  switchToAPMode = (event: any) => {
    this.setState({ switchToAPModeLoading: true });
    event.target.disabled = true;
    API.setAPMode().then(
      (msg) => {
        Notify(msg);
        this.setState({ switchToAPModeLoading: false });
      },
      (error) => {
        Notify(error);
        this.setState({ switchToAPModeLoading: false });
      }
    );
  };

  /**------------- */

  submitConf = (event: any) => {
    event.preventDefault();
    var data = {
      fan_trigger_temp: parseFloat(event.target.fan.value),
      oled_halt_timeout: parseInt(event.target.oled.value),
    };

    this.setState({ setConfLoading: true });

    API.setConf(data).then(
      (msg) => {
        Notify(msg);
        this.setState({ setConfLoading: false });
      },
      (error) => {
        Notify(error);
        this.setState({ setConfLoading: false });
      }
    );
  };

  /**------------- */

  render() {
    if (this.state.error) {
      return <ErrorComp error={this.state.error} />;
    }

    if (!this.state.APInfo) {
      return <LoadingSpinner />;
    }

    return (
      <React.Fragment>
        <div className="container mt-4">
          <div className="row mt-6">
            <div className="col-lg-6 mb-6 grid-margin">
              <div className="card h-100">
                <h4 className="card-header">Access Point Settings</h4>
                <div className="card-body">
                  <MDBContainer>
                    <MDBRow>
                      <MDBCol md="10">
                        <form onSubmit={this.submitSSID}>
                          <div className="grey-text">
                            <MDBInput
                              label="Type your SSID"
                              icon="wifi"
                              required
                              outline
                              valueDefault={this.state.APInfo.SSID}
                              name="SSID"
                            />
                            <MDBInput
                              label="Type your password"
                              icon="lock"
                              required
                              outline
                              valueDefault={this.state.APInfo.password}
                              name="password"
                            />
                          </div>
                          <div className="text-center">
                            <MDBBtn type="submit">
                              Save
                              {this.state.setAPInfoLoading ? (
                                <MDBIcon
                                  icon="cog"
                                  className="ml-2"
                                  size="1x"
                                  spin
                                />
                              ) : (
                                ""
                              )}
                            </MDBBtn>
                          </div>
                        </form>
                      </MDBCol>
                    </MDBRow>
                  </MDBContainer>
                </div>
              </div>
            </div>

            {/* The next Card */}

            <div className="col-lg-6 mb-6 grid-margin">
              <div className="card h-100">
                <h4 className="card-header">Access Point Mode</h4>
                <div className="card-body">
                  <MDBContainer>
                    <MDBRow>
                      <MDBCol md="10">
                        <form>
                          <div className="text-center">
                            <MDBAlert color="warning" className="text-justify">
                              <b>Warning:</b> If you are using WiFi to access
                              your gateway, after pushing this button, you will
                              need to connect to the Wazigate Hotspot in order
                              to control your gateway.
                            </MDBAlert>
                            <MDBBtn
                              disabled={
                                this.state.WiFiInfo &&
                                this.state.WiFiInfo.ap_mode
                              }
                              onClick={this.switchToAPMode}
                            >
                              Switch to Access Point Mode
                            </MDBBtn>
                            {this.state.switchToAPModeLoading ? (
                              <LoadingSpinner type="progress" />
                            ) : (
                              ""
                            )}
                          </div>
                        </form>
                      </MDBCol>
                    </MDBRow>
                  </MDBContainer>
                </div>
              </div>
            </div>

            {/* The next card */}

            <div className="col-lg-6 mt-3 mb-6 grid-margin">
              <div className="card h-100">
                <h4 className="card-header">Misc. Settings</h4>
                <div className="card-body">
                  <MDBContainer>
                    <MDBRow>
                      <MDBCol md="10">
                        <form onSubmit={this.submitConf}>
                          <div className="grey-text">
                            <MDBInput
                              label="Fan Trigger Temperature (C)"
                              icon="fan"
                              required
                              outline
                              type="number"
                              valueDefault={
                                this.state.ConfInfo
                                  ? this.state.ConfInfo.fan_trigger_temp
                                  : "Loading..."
                              }
                              name="fan"
                            />

                            <MDBInput
                              label="OLED halt timeout (seconds)"
                              icon="tv"
                              required
                              outline
                              type="number"
                              valueDefault={
                                this.state.ConfInfo
                                  ? this.state.ConfInfo.oled_halt_timeout
                                  : "Loading..."
                              }
                              name="oled"
                            />
                          </div>
                          <div className="text-center">
                            <MDBBtn
                              type="submit"
                              disabled={this.state.ConfInfo == null}
                            >
                              Save{" "}
                              {this.state.setAPInfoLoading ? (
                                <MDBIcon
                                  icon="cog"
                                  className="ml-2"
                                  size="1x"
                                  spin
                                />
                              ) : (
                                ""
                              )}
                            </MDBBtn>
                            <br />
                          </div>
                        </form>
                      </MDBCol>
                    </MDBRow>
                  </MDBContainer>
                </div>
              </div>
            </div>

            {/* The next card */}

            <div className="col-lg-6 mt-3 mb-6 grid-margin">
              <div className="card h-100">
                <h4 className="card-header">Timezone</h4>
                <div className="card-body">
                  <MDBContainer>
                    <MDBRow>
                      <MDBCol md="10">
                        <Clock interval={3} />
                        <TimezoneConfig />
                      </MDBCol>
                    </MDBRow>
                  </MDBContainer>
                </div>
              </div>
            </div>

            {/*----------------*/}
          </div>
        </div>
      </React.Fragment>
    );
  }
}

export default PagesConfig;
