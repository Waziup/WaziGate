import * as React from "react";
import * as API from "../api";
import { Route, Link, HashRouter as Router } from "react-router-dom";
import MenuBar from "./MenuBar";

import PagesOverview from "./Pages/Overview";
import PagesConfig from "./Pages/Config";
import PagesInternet from "./Pages/Wifi/Internet";
import PagesResources from "./Pages/Resources";
import PagesContainers from "./Pages/Containers/Containers";
import PagesLogs from "./Pages/Logs";
import PagesUpdate from "./Pages/Update";

import "../style/app.scss";
import "@fortawesome/fontawesome-free/css/all.min.css";
import "bootstrap-css-only/css/bootstrap.min.css";
import "mdbreact/dist/css/mdb.css";
import Notifications from "./Notifications";

export interface AppCompState {
  pageComp: JSX.Element;
}

export interface AppCompProps {
  hideLoader: Function;
  showLoader: Function;
}

class AppComp extends React.Component<AppCompProps, AppCompState> {
  constructor(props: AppCompProps) {
    super(props);
  }

  /*---------*/

  componentDidMount() {
    this.props.hideLoader();
  }

  /*---------*/

  render() {
    return (
      <Router>
        <React.Fragment>
          <MenuBar />
          {/* <Route path="/:active?" component={MenuBar} /> */}
          <div>
            <Route exact path="/" render={(props) => <PagesOverview />} />
            <Route path="/overview" component={PagesOverview} />
            <Route path="/config" component={PagesConfig} />
            <Route path="/internet" component={PagesInternet} />
            <Route path="/resources" component={PagesResources} />
            <Route path="/containers" component={PagesContainers} />
            <Route path="/logs" component={PagesLogs} />
            <Route path="/update" component={PagesUpdate} />
            {/* <Route path="/test" component={PagesTest} /> */}

            {/* <Route component={Notfound} />   */}
          </div>
          <Notifications />
        </React.Fragment>
      </Router>
    );
  }
}

export default AppComp;
