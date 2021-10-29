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
  // MDBIcon,
  // MDBListGroup,
  // MDBAlert,
} from "mdbreact";
import ContainerLogsItem from "./Containers/ContainerLogsItem";
import LoadingSpinner from "../LoadingSpinner";

declare function Notify(msg: string): any;

export interface Props {}
export interface State {
  cInfo: API.cInfo[];
  error: any;
  activeItem: any;
}

class Logs extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      cInfo: null,
      error: null,
      activeItem: 0,
    };
  }

  /**------------- */
  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
    API.getAllContainers().then(
      (info) => {
        this.setState({
          cInfo: info,
          error: null,
        });
      },
      (error) => {
        this.setState({
          cInfo: null,
          error: error,
        });
      }
    );
    // if( !this._isMounted) return;
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  /**------------- */

  toggle = (tab: any) => () => {
    if (this.state.activeItem !== tab) {
      this.setState({
        activeItem: tab,
      });
    }
  };

  /**------------- */

  render() {
    if (this.state.error) {
      return <ErrorComp error={this.state.error} />;
    }

    if (!this.state.cInfo) {
      return <LoadingSpinner />;
    }

    var tabHeads = this.state.cInfo
      ? this.state.cInfo.map((res, index) => (
          <MDBNavItem key={index}>
            <MDBNavLink
              to="#"
              link
              active={this.state.activeItem == index}
              activeClassName="active-link"
              onClick={this.toggle(index)}
              // role="tab"
              // className="bg-info"
            >
              {/* <MDBIcon fab icon="sketch" />  */}
              {res.Names.slice(0)[0].substr(1)}
            </MDBNavLink>
          </MDBNavItem>
        ))
      : "";

    var tabPanes = this.state.cInfo
      ? this.state.cInfo.map((res, index) => (
          <MDBTabPane
            tabId={index}
            role="tabpanel"
            key={index}
            className="centered text-center"
            style={{ minHeight: "200px" }}
          >
            <ContainerLogsItem
              cId={res.Id}
              active={this.state.activeItem == index}
              cName={res.Names.slice(0)[0].substr(1)}
            />
          </MDBTabPane>
        ))
      : "";

    return (
      <MDBContainer className="mt-3">
        <MDBNav pills className="nav md-pills nav-pills flex-column">
          {tabHeads}
        </MDBNav>
        <MDBTabContent className="card p-2" activeItem={this.state.activeItem}>
          {tabPanes}
        </MDBTabContent>
      </MDBContainer>
    );
  }
}

export default Logs;
