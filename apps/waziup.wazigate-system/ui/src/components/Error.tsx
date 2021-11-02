import * as React from "react";

interface ErrorProps {
	error: any;
}

export const ErrorComp = (props: ErrorProps) => {
	console.log(props);
	var msg = `${props.error}`;

	var match = msg.match(/^.+?\n/);
	var title = match && match.length ? match[0] : "Unknown";
	var text = match ? msg.slice(title.length) : msg;

	return (
		<div className="error">
			<h2>{title}</h2>
			<pre>{text}</pre>
		</div>
	);
};

export default ErrorComp;
