import * as React from "react";
import * as API from "../../../api";
import ErrorComp from "../../Error";

import {
  MDBContainer,
  MDBRow,
  MDBCol,
  // MDBInput,
  // MDBBtn,
  // MDBAlert,
  // MDBIcon
} from "mdbreact";

import ContainerItem from "./ContainerItem";

import LoadingSpinner from "../../LoadingSpinner";

declare function Notify(msg: string): any;

export interface Props {}
export interface State {
  cInfo: API.cInfo[];
  error: any;
  submitLoading: boolean;
}

class PagesContainers extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      cInfo: null,
      error: null,
      // switchToAPModeLoading: false,
      submitLoading: false,
    };
  }

  /**------------- */

  _isMounted = false;
  componentDidMount() {
    this._isMounted = true;
    this.updatePage();
    // if( !this._isMounted) return;
  }
  componentWillUnmount() {
    this._isMounted = false;
  }
  /**------------- */

  /**------------- */

  updatePage() {
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
  }

  /**------------- */

  render() {
    if (this.state.error) {
      return <ErrorComp error={this.state.error} />;
    }

    if (!this.state.cInfo) {
      return <LoadingSpinner />;
    }

    var results = this.state.cInfo
      ? this.state.cInfo.map((res, index) => (
          <MDBCol key={index}>
            <ContainerItem data={res} />
          </MDBCol>
        ))
      : "";

    return (
      <React.Fragment>
        <MDBContainer>
          <MDBRow>{results}</MDBRow>
        </MDBContainer>
      </React.Fragment>
    );
  }
}

export default PagesContainers;
