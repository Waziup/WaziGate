import * as React from "react";
import Menu, { SubMenu, Item as MenuItem, Divider } from "rc-menu";
import "../style/menubar.less";
import AppComp from "./App";
import InternetIndicator from "./InternetIndicator";

import { Navbar, Nav, NavDropdown } from "react-bootstrap";
import { MDBIcon } from "mdbreact";

/*-----------*/

export interface MenuProps {}
export interface MenuState {}

class MenuBar extends React.Component<MenuProps, MenuState> {
  constructor(props: MenuProps) {
    super(props);
  }

  render() {
    // alert(this.match.params.active);

    return (
      <Navbar
        expand="lg"
        variant="dark"
        // bg="dark"
        style={{ backgroundColor: "#34425A" }}
      >
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav
            className="mr-auto"
            // activeKey="#configs"
            variant="pills"
            // onSelect={(href: any) => this.handleClick(href)}
          >
            <Nav.Link href="#overview">
              <MDBIcon icon="heartbeat" /> Overview
            </Nav.Link>
            <NavDropdown
              title="Configurations"
              // href="#configs"
              id="basic-nav-dropdown"
            >
              <NavDropdown.Item href="#config">
                <MDBIcon icon="cog" /> Configuration
              </NavDropdown.Item>
              {/* <NavDropdown.Item href="#advance_config">
											advance_config
										</NavDropdown.Item> */}
              <NavDropdown.Item href="#internet">
                <MDBIcon icon="wifi" /> Internet
              </NavDropdown.Item>
              {/* <NavDropdown.Divider />
							<NavDropdown.Item href="#setup_wizard">
								<MDBIcon icon="magic" /> Setup Wizard
							</NavDropdown.Item> */}
            </NavDropdown>
            <NavDropdown title="Maintenance" id="basic-nav-dropdown">
              <NavDropdown.Item href="#resources">
                <MDBIcon fab icon="whmcs" /> Resources
              </NavDropdown.Item>
              <NavDropdown.Item href="#containers">
                <MDBIcon icon="docker" brand /> Containers
              </NavDropdown.Item>
              <NavDropdown.Item href="#logs">
                <MDBIcon icon="file-alt" /> Logs
              </NavDropdown.Item>
              {/* <NavDropdown.Divider />
              <NavDropdown.Item href="#update">
                <MDBIcon icon="sync" /> Update
              </NavDropdown.Item> */}
            </NavDropdown>
          </Nav>
          <Nav className="navbar-right">
            <InternetIndicator />
          </Nav>
        </Navbar.Collapse>
      </Navbar>
    );
  }

  onSelect(command: string) {
    console.log("Selected: %s", command);
  }
}
export default MenuBar;
