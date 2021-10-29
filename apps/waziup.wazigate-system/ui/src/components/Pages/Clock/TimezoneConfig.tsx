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
import Select from "react-select";

import LoadingSpinner from "../../LoadingSpinner";
import { Item } from "rc-menu";
// import { type } from "os";

declare function Notify(msg: string): any;

export interface Props { }

export interface State {
  loading: boolean;
  timezone: string;
  zonesList: string[];
  timezoneAuto: string;
}

class TimezoneConfig extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      loading: true,
      timezone: null,
      zonesList: null,
      timezoneAuto: null,
    };
  }

  /**------------- */

  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
    this.loadTimezones();
    this.load();
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  load() {
    if (!this._isMounted) return;

    this.setState({ loading: true });
    API.getConf().then(
      (res) => {
        this.setState({
          timezone: res.local_timezone ? res.local_timezone : "",
          loading: false,
        });
      },
      (error) => {
        Notify(error);
        this.setState({ loading: false });
      }
    );


  }

  /**------------- */

  loadTimezones() {
    if (!this._isMounted || this.state.zonesList) return;

    this.setState({ loading: true });
    API.getTimezones().then(
      (res) => {
        this.setState({
          zonesList: res,
          loading: false,
        });
      },
      (error) => {
        Notify(error);
        this.setState({ loading: false });
      }
    );

    API.getTimezoneAuto().then(
      (res) => {
        this.setState({
          timezoneAuto: res,
        });
      },
      (error) => { }
    );

  }

  /**------------- */

  handleSaveTimezone = (input: any) => {
    if (!input || !input.value) return;

    this.setState({ loading: true });
    API.setTimezone(input.value).then(
      (res) => {
        this.setState({
          loading: false,
          timezone: input.value,
        });
        Notify("The time zone set");
      },
      (error) => {
        Notify(error);
        this.setState({ loading: false });
      }
    );
  };

  /**------------- */

  render() {
    if (this.state.timezone === null) {
      // return <MDBIcon icon="cog" size="2x" spin />;
      return <LoadingSpinner type="grow" class="mt-5" />;
    }

    const zoneOptions = [{ value: "auto", label: "Automatic" + (this.state.timezoneAuto ? (" ( " + this.state.timezoneAuto + " ) ") : "") }];
    var defZoneId = 0;
    if (this.state.zonesList) {
      for (var i = 0; i < this.state.zonesList.length; i++) {
        if (this.state.timezone == this.state.zonesList[i]) defZoneId = i + 1;
        zoneOptions.push({
          value: this.state.zonesList[i],
          label: this.state.zonesList[i],
        });
      }
    }

    return (
      <React.Fragment>
        <MDBAlert color="info">
          Set Timezone:
          <MDBIcon
            spin
            icon="cog"
            style={{ display: this.state.loading ? "" : "none" }}
          />
          {this.state.zonesList && (
            <Select
              defaultValue={zoneOptions[defZoneId]}
              options={zoneOptions}
              onChange={this.handleSaveTimezone}
            />
          )}
        </MDBAlert>
      </React.Fragment>
    );
  }
}

export default TimezoneConfig;
