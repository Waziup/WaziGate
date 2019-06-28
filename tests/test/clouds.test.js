let chai = require('chai');
let chaiHttp = require('chai-http');
let should = chai.should();

let cloud = require('./sample-data').valid.cloud;
let device = require('./sample-data').valid.device;
let sensor = device.sensors[0];
let actuator = device.actuators[0];
let value = require('./sample-data').valid.value;

const {
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
} = require('./utils');

chai.use(chaiHttp);
chai.Assertion.includeStack = true;

describe('Clouds', () => {

  it('must connect to waziup.io', async () => {
    await deleteCloud(cloud);
    await sleep(1000);

    
    let resp = await createCloud(cloud);
    resp.should.have.status(200);
    
    await sleep(2000);

    resp = await getCloud(cloud);
    resp.should.have.status(200);
    resp.body.should.have.property('id').eql(cloud.id);
    resp.body.should.have.property('statusCode').eql(200);
  });

  it('must successfully pause', async () => {
    await pauseCloud(cloud);
    await sleep(3000);

    resp = await getCloud(cloud)
    resp.body.should.have.property('statusCode').eql(0);
  });

  it('must successfully resume', async () => {
    await resumeCloud(cloud);
    await sleep(3000);

    resp = await getCloud(cloud);
    resp.body.should.have.property('statusCode').eql(200);
  });

  it('must sync devices', async () => {
    await createDevice(device);
    await sleep(1000);
    resp = await getCloudDevice(device);
    resp.should.have.status(200);
    resp.body.should.have.property('id').eql(device.id);
  });

  it('must sync sensor values', async () => {
    value.value = Math.random();
    await postValue(device, sensor, value);
    await sleep(1000);
    resp = await getCloudValues(device, sensor);
    resp.body.should.satisfy((values) => values.find((val) => val.value == value.value))
  });

  it('must sync actuator values', async (done) => {

    let mqttLocal = await mqttConnect(); 
    let mqttCloud = await mqttCloudConnect();

    let topic = `devices/${device.id}/actuators/${actuator.id}/value`;

    await mqttLocal.subscribe(topic);
    mqttLocal.on('message', (topic2, message) => {
      expect(topic2).to.equal(topic)
      mqttLocal.end()
      mqttCloud.end()
      done();
    });

    mqttCloud.publish(topic, JSON.stringify(value))
  });
})