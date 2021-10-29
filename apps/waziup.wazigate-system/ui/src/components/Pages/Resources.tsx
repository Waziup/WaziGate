import * as React from "react";
import * as API from "../../api";
import ErrorComp from "../Error";
import LoadingSpinner from "../LoadingSpinner";

import { MDBContainer, MDBRow, MDBCol, MDBAlert, MDBProgress } from "mdbreact";

import ReactSpeedometer from "react-d3-speedometer";
// https://www.npmjs.com/package/react-d3-speedometer

import { Line } from "react-chartjs-2";
const totalChartPpoints = 50;

declare function Notify(msg: string): any;

export interface Props {}
export interface State {
	UsageInfoResults: API.UsageInfo;
	error: any;
	UsageInfoLoading: boolean;

	cpuData: any;
	tmpData: any;
	memData: any;
}

class PagesInternet extends React.Component<Props, State> {
	constructor(props: Props) {
		super(props);
		this.state = {
			UsageInfoResults: null,
			UsageInfoLoading: true,
			error: null,
			// isMounted: false,

			cpuData: [0],
			tmpData: [0],
			memData: [0]
		};
	}

	/**------------- */

	updateChartsData() {
		var arrCpuData = this.state.cpuData;
		var arrMemData = this.state.memData;
		var arrTmpData = this.state.tmpData;

		if (arrCpuData.length > totalChartPpoints) {
			arrCpuData.shift();
			arrMemData.shift();
			arrTmpData.shift();
		}

		arrCpuData.push(parseInt(this.state.UsageInfoResults.cpu_usage));
		arrMemData.push(
			Math.round(
				(100 * parseInt(this.state.UsageInfoResults.mem_usage.used)) /
					parseInt(this.state.UsageInfoResults.mem_usage.total)
			)
		);
		arrTmpData.push(parseInt(this.state.UsageInfoResults.temp));

		this.setState({
			cpuData: arrCpuData,
			memData: arrMemData,
			tmpData: arrTmpData
		});
	}

	/**------------- */

	getChartData(chartId: number) {
		var dataSet;
		switch (chartId) {
			case 1:
				dataSet = this.state.cpuData;
				break;
			case 2:
				dataSet = this.state.cpuData;
				break;
			case 3:
				dataSet = this.state.cpuData;
				break;
		}

		// console.log(dataSet);

		return {
			labels: new Array(totalChartPpoints).fill(""),
			datasets: [
				{
					label: "CPU",
					fill: false,
					data: dataSet
				}
			]
		};
	}

	/**------------- */

	_isMounted = false;
	componentDidMount() {
		this._isMounted = true;
		this.load();
	}
	componentWillUnmount() {
		this._isMounted = false;
	}
	/**------------- */

	load() {
		if (!this._isMounted) return;

		this.setState({
			UsageInfoLoading: true
		});

		API.getUsageInfo().then(
			results => {
				// console.log(results);
				this.setState({
					UsageInfoResults: results,
					UsageInfoLoading: false
				});

				this.updateChartsData();

				setTimeout(() => {
					this.load();
				}, 2000); // 2 seconds
			},
			error => {
				this.setState({
					UsageInfoLoading: false,
					error: error
				});

				setTimeout(() => {
					this.load();
				}, 2000); // 2 seconds
			}
		);
	}

	/**------------- */

	render() {
		if (this.state.error) {
			return <ErrorComp error={this.state.error} />;
		}

		if (!this.state.UsageInfoResults) {
			return <LoadingSpinner />;
		}

		const data = (canvas: any) => {
			// console.log(this.state.cpuData.slice(0));
			return {
				labels: new Array(totalChartPpoints).fill(""),
				datasets: [
					{
						label: "CPU",
						fill: false,
						// backgroundColor: "rgba(184, 185, 210, .3)",
						borderColor: "#AC64AD",
						pointRadius: 0,
						data: this.state.cpuData.slice(0)
					},
					{
						label: "Memory",
						fill: false,
						// backgroundColor: "rgba(184, 185, 210, .3)",
						borderColor: "#0d47a1",
						pointRadius: 0,
						data: this.state.memData.slice(0)
					},
					{
						label: "Temperature",
						fill: false,
						// backgroundColor: "rgba(184, 185, 210, .3)",
						borderColor: "#e65100",
						pointRadius: 0,
						data: this.state.tmpData.slice(0)
					}
				]
			};
		};

		function humanFileSize(size: any) {
			var i = Math.floor(Math.log(size) / Math.log(1024));
			return (
				((size / Math.pow(1024, i)).toFixed(2) as any) * 1 +
				" " +
				["B", "kB", "MB", "GB", "TB"][i]
			);
		}

		return (
			<MDBContainer className="mt-3">
				<MDBRow className="text-center">
					<MDBCol sm="4">
						<ReactSpeedometer
							maxValue={100}
							value={parseInt(this.state.UsageInfoResults.cpu_usage)}
							// needleColor="black"
							startColor="#fbe9e7"
							height={200}
							segments={1000}
							maxSegmentLabels={5}
							endColor="#bf360c"
							currentValueText="CPU: ${value} %"
						/>
					</MDBCol>
					<MDBCol sm="4">
						<ReactSpeedometer
							maxValue={Math.round(
								parseInt(this.state.UsageInfoResults.mem_usage.total) / 1024
							)}
							value={Math.round(
								parseInt(this.state.UsageInfoResults.mem_usage.used) / 1024
							)}
							// needleColor="black"
							startColor="#e3f2fd"
							height={200}
							segments={1000}
							maxSegmentLabels={4}
							endColor="#0d47a1"
							currentValueText="Memory: ${value} MB"
						/>
					</MDBCol>
					<MDBCol sm="4">
						<ReactSpeedometer
							maxValue={100}
							value={parseInt(this.state.UsageInfoResults.temp)}
							// needleColor="black"
							startColor="#fff3e0"
							height={200}
							segments={1000}
							maxSegmentLabels={5}
							endColor="#e65100"
							currentValueText="Temperature: ${value} C"
						/>
					</MDBCol>
				</MDBRow>

				<MDBRow className="mt-4">
					<MDBCol sm="12">
						<b>Disk</b>:{" "}
						<b>{humanFileSize(this.state.UsageInfoResults.disk.used)}</b>
						of <b>
							{humanFileSize(this.state.UsageInfoResults.disk.size)}
						</b>{" "}
						used
						<MDBProgress
							material
							value={parseInt(this.state.UsageInfoResults.disk.percent)}
							height="20px"
						>
							{this.state.UsageInfoResults.disk.percent}
						</MDBProgress>
					</MDBCol>
				</MDBRow>

				<MDBRow className="text-center mt-4">
					<MDBCol sm="12">
						<Line
							data={data}
							height={100}
							options={{
								responsive: true,
								spanGaps: true,

								scales: {
									yAxes: [{ ticks: { max: 100, min: 0, stepSize: 25 } }],
									xAxes: [
										{
											ticks: { display: false },
											gridLines: {
												display: false,
												drawBorder: false
											}
										}
									]
								}
								// legend: {
								// 	display: false
								// },
								// title: {
								// 	display: false
								// }
							}}
						/>
					</MDBCol>
				</MDBRow>
			</MDBContainer>
		);
	}
}

export default PagesInternet;
