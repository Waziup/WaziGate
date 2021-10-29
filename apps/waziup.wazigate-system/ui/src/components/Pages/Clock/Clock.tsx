import * as React from "react";
import * as API from "../../../api";

import {
  // MDBBtn,
  MDBCard,
  MDBCardBody,
  MDBCardTitle,
  // MDBCardText,
  MDBAlert,
  MDBIcon,
} from "mdbreact";

import LoadingSpinner from "../../LoadingSpinner";
// import { type } from "os";

declare function Notify(msg: string): any;

export interface Props {
  interval?: number;
}

type ClockData = {
  time: Date;
  utc: Date;
  zone: string;
};

export interface State {
  loading: boolean;
  data: ClockData;
}

class Clock extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      loading: true,
      data: null,
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

  incTimeout: any = null;
  loopLoad() {
    if (!this._isMounted) return;

    const incTime = () => {
      if (!this.state.data || this.state.data?.time == null || !this._isMounted) return;
      this.setState({
        data: {
          time: new Date(this.state.data.time.getTime() + 1000),
          utc: new Date(this.state.data.utc.getTime() + 1000),
          zone: this.state.data.zone,
        },
        loading: false,
      });
      this.incTimeout = setTimeout(incTime, 1000);
    };

    clearTimeout(this.incTimeout);

    this.setState({ loading: true });
    API.getTime().then(
      (res) => {
        this.setState({
          data: {
            time: isNaN(Date.parse(res.time)) ? null : new Date(res.time),
            utc: isNaN(Date.parse(res.utc)) ? null : new Date(res.utc),
            zone: res.zone,
          },
          loading: false,
        });
        this.incTimeout = setTimeout(incTime, 1000);
        setTimeout(
          () => {
            this.loopLoad();
          },
          this.props.interval ? this.props.interval * 1000 : 30000
        ); // Update the time from server every 30 seconds
      },
      (error) => {
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

    return (
      <React.Fragment>
        <MDBAlert color="info">
          <span className="text-capitalize">
            UTC Time :{" "}
            <b>
              {this.state.data.utc
                ? this.state.data.utc.toLocaleTimeString()
                : "---"}
            </b>
          </span>
        </MDBAlert>
        <MDBAlert color="info">
          <span className="text-capitalize">
            Local Time :{" "}
            <b>
              {this.state.data.time
                ? this.state.data.time.toLocaleTimeString()
                : "---"}
            </b>
          </span>
        </MDBAlert>
        <MDBAlert color="info">
          <span className="text-capitalize">
            Time Zone : <b>{this.state.data.zone}</b>
          </span>
        </MDBAlert>
        {/* // <MDBIcon
      //   spin={this.state.loading}
      //   icon={
      //     this.state.loading
      //       ? "cog"
      //       : this.props.icon
      //       ? this.props.icon
      //       : "wave-square"
      //   }
	  // />{" "} */}
      </React.Fragment>
    );
  }
}

export default Clock;
