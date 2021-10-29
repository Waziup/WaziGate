import * as React from "react";
import * as API from "../../../api";

import { MDBInput, MDBIcon, MDBBtn } from "mdbreact";
import LoadingSpinner from "../../LoadingSpinner";
// import LoadingSpinner from "../LoadingSpinner";

declare function Notify(msg: string): any;

export interface Props {
  active: boolean;
  cId: string;
  cName?: string;
}
export interface State {
  loading: boolean;
  dlLoading: boolean;
  data: any;
}

class ContainerLogsItem extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      loading: true,
      dlLoading: false,
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

  /**------------- */

  loopLoad() {
    if (!this._isMounted) return;

    if (this.props.active) {
      API.getContainerLogs(this.props.cId, 50).then(
        (res) => {
          this.setState({
            data: res,
          });
          setTimeout(() => {
            this.loopLoad();
          }, 1000); // Check every second
          this.setState({ loading: false });
        },
        (error) => {
          Notify(error);
          this.setState({ loading: false });
        }
      );
    } else {
      setTimeout(() => {
        this.loopLoad();
      }, 1000); // Check every second
    }
  }

  /**------------- */

  downloadLogs() {
    this.setState({ dlLoading: true });
    API.dlContainerLogs(this.props.cId).then(
      (res) => {
        res.blob().then((blob: any) => {
          let url = window.URL.createObjectURL(blob);
          let a = document.createElement("a");
          a.href = url;

          var today = new Date();
          var fileName =
            this.props.cName +
            "_" +
            today.getFullYear() +
            "-" +
            (today.getMonth() + 1) +
            "-" +
            today.getDate() +
            "_" +
            today.getHours() +
            "-" +
            today.getMinutes() +
            "-" +
            today.getSeconds() +
            ".logs";

          a.download = fileName;
          a.click();
        });
        this.setState({ dlLoading: false });
      },
      (error) => {
        Notify(error);
        this.setState({ dlLoading: false });
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
      <div>
        <textarea
          rows={22}
          className="bg-dark text-light form-control form-rounded"
          // spellCheck={false}
          // contentEditable={false}
          readOnly={true}
          //   value={this.state.data.textContent()}
          value={this.state.data}
        ></textarea>

        <br />
        <hr />

        <a href={"../docker/" + this.props.cId + "/logs"} target="_blank">
				  <MDBIcon icon="download" />{"  "}Download all logs
				</a>
        <br />
      </div>
    );
  }
}

export default ContainerLogsItem;
