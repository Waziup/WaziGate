import * as React from "react";
import * as API from "../../../api";

import {
  MDBBtn,
  MDBCard,
  MDBCardBody,
  MDBCardTitle,
  MDBCardText,
  MDBAlert,
  MDBIcon,
} from "mdbreact";
import LoadingSpinner from "../../LoadingSpinner";

declare function Notify(msg: string): any;

export interface Props {
  data: API.cInfo;
}
export interface State {
  hideForm: boolean;
  setStartLoading: boolean;
  setStopLoading: boolean;
  data: API.cInfo;
}

class ContainerItem extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      hideForm: true,
      setStartLoading: false,
      setStopLoading: false,
      data: null,
    };
  }

  /**------------- */

  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
    this.setState({
      data: this.props.data,
    });
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  /**------------- */

  setContainerAction(action: string) {
    this.setState({
      setStartLoading: action == "start",
      setStopLoading: action == "stop",
    });

    API.setContainerAction(this.props.data.Id, action).then(
      (msg) => {
        Notify(msg);

        API.getContainer(this.props.data.Id).then(
          (cInfo) => {
            this.setState({
              setStartLoading: false,
              setStopLoading: false,
              data: cInfo,
            });
          },
          (error) => {
            Notify(error);
            this.setState({ setStartLoading: false, setStopLoading: false });
          }
        );
      },
      (error) => {
        Notify(error);
        this.setState({ setStartLoading: false, setStopLoading: false });
      }
    );
  }

  /**------------- */

  render() {
    if (!this.state.data) {
      return <MDBIcon icon="cog" size="3x" spin />;
    }

    var isRunning = this.state.data.State == "running";

    return (
      <MDBCard style={{ width: "22rem" }} className="mt-3">
        <MDBCardBody>
          <MDBCardTitle title={"Image: " + this.state.data.Image}>
            {isRunning ? (
              <MDBIcon icon="play" className="text-primary" title="Running" />
            ) : (
              <MDBIcon
                icon="exclamation-triangle"
                className="text-warning"
                title="Stopped"
              />
            )}{" "}
            {this.state.data.Names.slice(0)[0].substr(1)}
          </MDBCardTitle>
          <MDBAlert color={isRunning ? "info" : "warning"}>
            {this.state.data.Status}
          </MDBAlert>
          {/* <MDBAlert color="info">Id: {this.state.data.Id}</MDBAlert> */}
          <MDBBtn
            disabled={!isRunning}
            title="Stop"
            onClick={() => this.setContainerAction("stop")}
          >
            <MDBIcon
              icon={this.state.setStopLoading ? "cog" : "stop"}
              spin={this.state.setStopLoading}
            />
          </MDBBtn>
          <MDBBtn
            disabled={isRunning}
            title="Start"
            onClick={() => this.setContainerAction("start")}
          >
            <MDBIcon
              icon={this.state.setStartLoading ? "cog" : "play"}
              spin={this.state.setStartLoading}
            />
          </MDBBtn>
        </MDBCardBody>
      </MDBCard>
    );
  }
}

export default ContainerItem;
