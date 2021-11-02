import React from "react";
import { NotificationStack } from "react-notification";

export interface Props {}
export interface State {
	notifications: any;
	count: number;
}

class Notifications extends React.Component<Props, State> {
	constructor(props: Props) {
		super(props);

		this.state = {
			notifications: [],
			count: 0
		};

		this.add = this.add.bind(this);
		this.remove = this.remove.bind(this);

		(window as any)["Notify"] = this.add;
	}

	/*---------------*/

	add(msg: string) {
		const { notifications, count } = this.state;

		const id = notifications.size + 1;
		const newCount = count + 1;

		this.setState({
			count: newCount,
			notifications: [
				{
					message: msg,
					key: newCount,
					action: "Dismiss",
					dismissAfter: 4000
				},
				...notifications
			]
		});
	}

	remove(notification: any) {
		const { notifications } = this.state;

		this.setState({
			notifications: notifications.filter(
				(n: { key: any }) => n.key !== notification.key
			)
		});
	}

	render() {
		return (
			<React.Fragment>
				<NotificationStack
					notifications={this.state.notifications}
					onDismiss={this.remove}
				/>
			</React.Fragment>
		);
	}
}

export default Notifications;
