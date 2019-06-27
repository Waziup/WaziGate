const chai = require('chai');
const chaiHttp = require('chai-http');
const MQTT = require("async-mqtt");

const {
  edge,
  cloud,
  mqtt,
  mqttCloud
} = require('./config.json');

chai.use(chaiHttp);

function sleep(millis) {
  return new Promise(resolve => setTimeout(resolve, millis));
}

const createCloud = (cloud) => chai.request(edge).post(`/clouds`).send(cloud);
const getCloud = (cloud) => chai.request(edge).get(`/clouds/${cloud.id}`);
const deleteCloud = (cloud) => chai.request(edge).delete(`/clouds/${cloud.id}`);
const pauseCloud = (cloud) => chai.request(edge).post(`/clouds/${cloud.id}/paused`).send(Buffer.from("true"));
const resumeCloud = (cloud) => chai.request(edge).post(`/clouds/${cloud.id}/paused`).send(Buffer.from("false"));

const createDevice = (device) => chai.request(edge).post(`/devices`).send(device);
const postValue = (device, sensor, value) => chai.request(edge).post(`/devices/${device.id}/sensors/${sensor.id}/value`).send(value);

const getCloudDevice = (device) => chai.request(cloud).get(`/devices/${device.id}`);
const getCloudValues = (device, sensor) => chai.request(cloud).get(`/sensors_data?device_id=${device.id}&sensor_id=${sensor.id}&sort=dsc&calibrated=true&limit=100`);

const mqttConnect = () => new Promise((resolve, reject) => {
  let client = MQTT.connect(mqtt); 
  client.on('connect', () => resolve(client));
  client.on("error", (err) => { throw err });
});

const mqttCloudConnect = () => new Promise((resolve, reject) => {
  let client = MQTT.connect(mqttCloud); 
  client.on('connect', () => resolve(client));
  client.on("error", (err) => { throw err });
});

module.exports = {
  sleep,
  createCloud,
  getCloud,
  deleteCloud,
  pauseCloud,
  resumeCloud,
  createDevice,
  postValue,
  getCloudDevice,
  getCloudValues,
  mqttConnect,
  mqttCloudConnect
}