import * as React from "react";
import { Component } from "react";
import * as API from "../../api";
import ErrorComp from "../Error";
// import LoadingSpinner from "../LoadingSpinner";
import Clock from "./Clock/Clock";
import Modal from 'react-bootstrap/Modal'

// import { Accordion, Card } from "react-bootstrap";
declare function Notify(msg: string): any;



import {
  MDBContainer,
  MDBRow,
  MDBCol,
  // MDBInput,
  MDBBtn,
  MDBAlert,
  MDBIcon,
  // MDBModal,
  // MDBModalBody,
  // MDBModalHeader,
  // MDBModalFooter,

  // MDBCard,
  // MDBCardBody,
  // MDBCardTitle,
  // MDBCardText,
} from "mdbreact";

import SensorItem from "./SensorItem";

export interface Props {}
export interface State {
  netInfo: API.NetInfo;
  allSensors: any;
  blackout: boolean;
  error: any;
  WiFiInfo: API.WiFiInfo;
  WiFiLoading: boolean;
  modal: {
    visible: boolean;
    title: string;
    msg: string;
    func: string;
  };
  shutdownLoading: boolean;
  rebootLoading: boolean;
}

class PagesOverview extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      netInfo: null,
      allSensors: null,
      blackout: null,
      WiFiInfo: null,
      WiFiLoading: true,
      error: null,
      modal: {
        visible: false,
        title: "",
        msg: "",
        func: "",
      },
      shutdownLoading: false,
      rebootLoading: false,
    };
  }

  /**------------- */
  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
    API.getNetInfo().then(
      (res) => {
        this.setState({
          netInfo: res,
          error: null,
        });
      },
      (error) => {
        this.setState({
          netInfo: null,
          error: error,
        });
      }
    );

    /*-------*/

    // API.getAllSensors().then(
    // 	res => {
    // 		this.setState({
    // 			allSensors: res,
    // 			error: null
    // 		});
    // 	},
    // 	error => {
    // 		this.setState({
    // 			allSensors: null,
    // 			error: error
    // 		});
    // 	}
    // );

    API.getBlackout().then(
      (res) => {
        this.setState({
          blackout: res,
        });
      },
      (error) => {
        this.setState({
          blackout: null,
        });
      }
    );

    this.updateWiFiInfo();

    // if( !this._isMounted) return;
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  updateWiFiInfo() {
    if (!this._isMounted) return;

    this.setState({
      WiFiLoading: true,
    });

    API.getWiFiInfo().then(
      (WiFiInfo) => {
        // console.log(WiFiInfo);
        this.setState({
          WiFiInfo: WiFiInfo,
          error: null,
          WiFiLoading: false,
        });
        setTimeout(() => {
          this.updateWiFiInfo();
        }, 5000); // Check every 5 seconds
      },
      (error) => {
        this.setState({
          WiFiInfo: null,
          error: error,
          WiFiLoading: false,
        });
        setTimeout(() => {
          this.updateWiFiInfo();
        }, 5000);
      }
    );
  }

  /**------------- */

  shutdown() {
    if (!this._isMounted) return;

    this.setState({
      shutdownLoading: true,
    });

    API.shutdown().then(
      (res) => {
        Notify(res);
      },
      (error) => {
        console.log(error);
        this.setState({
          shutdownLoading: false,
        });
      }
    );

    this.componentWillUnmount();
  }

  /**------------- */

  reboot() {
    if (!this._isMounted) return;

    this.setState({
      rebootLoading: true,
    });

    API.reboot().then(
      (res) => {
        Notify(res);
      },
      (error) => {
        console.log(error);
        this.setState({
          rebootLoading: false,
        });
      }
    );
    this.componentWillUnmount();
  }
  /**------------- */

  showModal(title: string, msg: string, func: string) {
    this.setState({
      modal: {
        visible: true,
        title: title,
        msg: msg,
        func: func,
      },
    });
  }

  /**------------- */

  modalClick = () => {
    switch (this.state.modal.func) {
      case "reboot":
        this.reboot();
        break;
      case "shutdown":
        this.shutdown();
        break;
      default:
        console.log("No function found: ", this.state.modal.func);
    }
    this.toggleModal();
  };

  /**------------- */

  toggleModal = () => {
    this.setState({
      modal: {
        visible: !this.state.modal.visible,
        title: this.state.modal.title,
        msg: this.state.modal.msg,
        func: this.state.modal.func,
      },
    });
  };

  /**------------- */

  render() {

    if( this.state.shutdownLoading || this.state.rebootLoading)
    {
      return <div style={{marginTop: "20%", textAlign: "center", border: "1px solid #BBB", borderRadius: "5px",padding: "5%",marginLeft: "10%", marginRight: "10%", backgroundColor: "#EEE"}}>
        <h1>Wazigate is not accessible...</h1>
      </div>
    }

    if (this.state.error) {
      return <ErrorComp error={this.state.error} />;
    }

    var sensors = this.state.allSensors
      ? this.state.allSensors.map((res: any, index: React.ReactText) => (
          <SensorItem
            key={index}
            name={res.name}
            desc={res.description}
            icon={res.name == "si7021" ? "temperature-low" : ""}
          />
        ))
      : "";

    var wifiStatus = null;
    if (this.state.WiFiInfo) {
      if (this.state.WiFiInfo.ap_mode) {
        wifiStatus = (
          <span>
            <MDBAlert color="info">
              Mode:{" "}
              <b>
                Access Point <MDBIcon icon="broadcast-tower" />
              </b>
            </MDBAlert>
            <MDBAlert color="info">
              SSID:{" "}
              <b>
                {this.state.WiFiInfo.ssid ? (
                  this.state.WiFiInfo.ssid
                ) : (
                  <MDBIcon icon="spinner" spin />
                )}
              </b>
            </MDBAlert>
          </span>
        );
      } else {
        wifiStatus = (
          <span>
            <MDBAlert color="info">
              Mode:{" "}
              <b>
                WiFi Client <MDBIcon icon="wifi" />
              </b>
              {"  "}
              <span title={this.state.WiFiInfo.state}>
                {this.state.WiFiInfo.state ? (
                  this.state.WiFiInfo.state == "COMPLETED" ? (
                    <MDBIcon fas icon="check-circle" />
                  ) : (
                    <span>
                      <MDBIcon icon="spinner" spin />{" "}
                      {this.state.WiFiInfo.state}
                    </span>
                  )
                ) : (
                  "..."
                )}
              </span>
            </MDBAlert>
            <MDBAlert color="info">
              Connected to{" "}
              <b>
                {this.state.WiFiInfo.ssid ? (
                  this.state.WiFiInfo.ssid
                ) : (
                  <MDBIcon icon="spinner" spin />
                )}
              </b>
            </MDBAlert>
            <MDBAlert color="info">
              IP address:{" "}
              <b>
                {this.state.WiFiInfo.ip ? (
                  this.state.WiFiInfo.ip
                ) : (
                  <MDBIcon icon="spinner" spin />
                )}
              </b>
            </MDBAlert>
          </span>
        );
      }
    }

    return (
      <MDBContainer>
        <MDBRow>
          <MDBCol>
            <div className="card mb-3 mt-3 m-l3 mb-3">
              <h4 className="card-header">
                {" "}
                <MDBIcon
                  spin={this.state.netInfo == null}
                  icon={this.state.netInfo ? "network-wired" : "cog"}
                />{" "}
                Ethernet Network
              </h4>
              <div className="card-body">
                <MDBAlert color="info">
                  IP address :{" "}
                  <b>
                    {this.state.netInfo ? (
                      this.state.netInfo.ip
                    ) : (
                      <MDBIcon icon="spinner" spin />
                    )}
                  </b>
                </MDBAlert>
                <MDBAlert color="info">
                  MAC address :{" "}
                  <b>
                    {this.state.netInfo ? (
                      this.state.netInfo.mac
                    ) : (
                      <MDBIcon icon="spinner" spin />
                    )}
                  </b>
                </MDBAlert>
                <MDBAlert color="info">
                  Device :{" "}
                  <b>
                    {this.state.netInfo ? (
                      this.state.netInfo.dev
                    ) : (
                      <MDBIcon icon="spinner" spin />
                    )}
                  </b>
                </MDBAlert>
              </div>
            </div>
          </MDBCol>

          {}

          <MDBCol>
            <div className="card mb-3 mt-3 m-l3 mb-3">
              <h4 className="card-header">
                {" "}
                <MDBIcon
                  spin={this.state.WiFiLoading}
                  icon={this.state.WiFiLoading ? "cog" : "wifi"}
                />{" "}
                <a href="./#internet" title="Conenct to a WiFi network">
                  WiFi Network
                </a>
              </h4>
              <div className="card-body">{wifiStatus}</div>
            </div>
          </MDBCol>
        </MDBRow>

        {}

        <MDBRow>
          <MDBCol>
            <div className="card mb-3 mt-3 m-l3 mb-3">
              <h4 className="card-header">
                <MDBIcon far icon="clock" />{" "}
                <a href="./#config" title="Click to change the Timezone">
                  Gateway Clock
                </a>
              </h4>
              <div className="card-body h-100">
                <Clock />
              </div>
            </div>
          </MDBCol>

          {}

          <MDBCol>
            <div className="card mb-3 mt-3 m-l3 mb-3">
              <h4 className="card-header">
                <MDBIcon icon="bolt" /> Blackout Protection
              </h4>
              <div className="card-body h-100">
                {this.state.blackout === null ? (
                  <MDBIcon icon="cog" spin />
                ) : this.state.blackout ? (
                  <span>
                    <MDBIcon className="green-text" icon="check-circle" />{" "}
                    Activated
                  </span>
                ) : (
                  <span>
                    <MDBIcon color="orange-text" icon="exclamation-circle" />{" "}
                    Not available
                  </span>
                )}
              </div>
            </div>

            {/* -------------------------- */}

            <div className="card mb-3 mt-3 m-l3 mb-3">
              <h4 className="card-header">
                <MDBIcon icon="power-off" /> Gateway Shutdown
              </h4>
              <div className="card-body">
                <MDBBtn
                  disabled={this.state.shutdownLoading}
                  onClick={() =>
                    this.showModal(
                      "Shutdown the Wazigate",
                      "Are you sure that you want to shutdown the gateway?",
                      "shutdown"
                    )
                  }
                >
                  <MDBIcon
                    icon={this.state.shutdownLoading ? "cog" : "power-off"}
                    className="ml-2"
                    size="1x"
                    spin={this.state.shutdownLoading}
                  />{" "}
                  Shutdown
                </MDBBtn>

                <MDBBtn
                  disabled={this.state.rebootLoading}
                  onClick={() =>
                    this.showModal(
                      "Restart the Wazigate",
                      "Are you sure that you want to restart the gateway?",
                      "reboot"
                    )
                  }
                >
                  <MDBIcon
                    icon={this.state.rebootLoading ? "cog" : "redo"}
                    className="ml-2"
                    size="1x"
                    spin={this.state.rebootLoading}
                  />{" "}
                  Restart
                </MDBBtn>
              </div>
            </div>
          </MDBCol>

          {}
        </MDBRow>

        <MDBRow>
          <MDBCol></MDBCol>
          <MDBCol></MDBCol>
        </MDBRow>

        {/*
        After some package update, thos modal just does not work!
         <MDBModal autoFocus isOpen={this.state.modal.visible} toggle={this.toggleModal}>
          <MDBModalHeader toggle={this.toggleModal}>
            {this.state.modal.title}
          </MDBModalHeader>
          <MDBModalBody>{this.state.modal.msg}</MDBModalBody>
          <MDBModalFooter>
            <MDBBtn color="secondary" onClick={this.toggleModal}>
              No
            </MDBBtn>
            <MDBBtn color="danger" onClick={this.modalClick}>
              Yes
            </MDBBtn>
          </MDBModalFooter>
        </MDBModal> */}

      <Modal show={this.state.modal.visible} onHide={this.toggleModal}>
        <Modal.Header closeButton>
          <Modal.Title>{this.state.modal.title}</Modal.Title>
        </Modal.Header>
        <Modal.Body>{this.state.modal.msg}</Modal.Body>
        <Modal.Footer>
          <MDBBtn onClick={this.toggleModal}>
              No
            </MDBBtn>
            <MDBBtn color="danger" onClick={this.modalClick}>
              Yes
            </MDBBtn>
        </Modal.Footer>
      </Modal>

      </MDBContainer>
    );
  }
}

export default PagesOverview;