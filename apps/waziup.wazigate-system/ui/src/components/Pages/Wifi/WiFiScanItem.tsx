import * as React from "react";
import * as API from "../../../api";
import { MDBListGroupItem, MDBInput, MDBIcon, MDBBtn } from "mdbreact";

declare function Notify(msg: string): any;

export interface Props {
  name: string;
  signal: string;
  empty?: boolean;
  active?: boolean;
}
export interface State {
  hideForm: boolean;
  setAPLoading: boolean;
}

class WiFiScanItem extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      hideForm: true,
      setAPLoading: false,
    };
  }

  /**------------- */

  /**------------- */
  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
    // if( !this._isMounted) return;
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  handleClick = (event: any) => {
    // event.preventDefault();
    this.setState({
      hideForm: false,
    });
  };

  /**------------- */

  submitHandler = (event: any) => {
    event.preventDefault();
    var data = {
      ssid: event.target.SSID.value,
      password: event.target.password.value,
    };

    this.setState({ setAPLoading: true });

    API.setWiFiConnect(data).then(
      (msg) => {
        Notify(msg);
        this.setState({ setAPLoading: false, hideForm: true });
      },
      (error) => {
        Notify(error);
        this.setState({ setAPLoading: false });
      }
    );
  };

  /**------------- */

  render() {
    return (
      <MDBListGroupItem
        className="d-flex justify-content-between align-items-center"
        onClick={this.handleClick}
        hover
        active={this.props.active}
      >
        <span hidden={!this.state.hideForm}>{this.props.name}</span>
        <form onSubmit={this.submitHandler} hidden={this.state.hideForm}>
          <MDBInput
            label="SSID"
            icon="wifi"
            required
            outline
            disabled={!this.props.empty}
            valueDefault={this.props.empty ? "" : this.props.name}
            name="SSID"
          />
          <MDBInput
            label="Type your password"
            icon="lock"
            required
            outline
            name="password"
            // type="password"
          />
          <div className="text-center">
            <MDBBtn type="submit" disabled={this.state.setAPLoading}>
              Connect
              {this.state.setAPLoading ? (
                <MDBIcon icon="cog" className="ml-2" size="1x" spin />
              ) : (
                ""
              )}
            </MDBBtn>
          </div>
        </form>
        <span className="" title={this.props.signal + " %"}>
          <MDBIcon
            icon="wifi"
            size="2x"
            fixed
            style={{ opacity: `${this.props.signal + "%"}` }}
          />
        </span>
      </MDBListGroupItem>
    );
  }
}

export default WiFiScanItem;
