## Waziup Gateway Tests

import json
import requests
from time import sleep
import unittest
import xmlrunner
import random
import logging
import time
import os
import sys
import logging
from xmlrunner import XMLTestRunner

logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True

## Variable declaration

wazidev_sensor_id = 'temperatureSensor_1'
wazidev_sensor_value = 45.7
wazidev_actuator_id = 'act1'
wazidev_actuator_value = json.dumps(True)

wazigate_ip = os.environ.get('WAZIGATE_IP', '172.16.11.186')
wazigate_url = 'http://' + wazigate_ip + '/'

wazigate_device = {
  'id': 'test000',
  'name': 'test',
  'sensors': [],
  'actuators': []
}

meta: {
  'codec': 'application/x-xlpp',
  'lorawan': {
    'appSKey': '23158D3BBC31E6AF670D195B5AED5525',
    'devAddr': '26011D22',
    'devEUI': 'AA555A0026011D01',
    'nwkSEncKey': '23158D3BBC31E6AF670D195B5AED5525',
    'profile': 'WaziDev'
  }
}

wazigate_create_actuator = {
  'id': 'act1',
  'name': 'act1'
}

auth = {
  "username": "admin",
  "password": "loragateway"
}

class TestWaziGateAuth(unittest.TestCase):

    def test_get_token(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.assertEqual(resp.status_code, 200)
        self.assertNotEqual(len(resp.text), 0)
        self.assertNotIn("\"", resp.text)

    def test_get_retoken(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        resp2 = requests.post(wazigate_url + '/auth/retoken', json = resp.text) 
        self.assertEqual(resp2.status_code, 200)
        self.assertNotEqual(len(resp2.text), 0)

    def test_get_profile(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        resp2 = requests.post(wazigate_url + '/auth/profile', json = resp.text) 
        self.assertEqual(resp2.status_code, 200)
        self.assertNotEqual(len(resp2.text), 0)

class TestWaziGateSelf(unittest.TestCase):
    token = None
    def setUp(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.token_header = {"Authorization": "Bearer " + resp.text.strip('"')}
        self.token = resp.text.strip('"')

    def test_get_id(self):
        """ Test get ID of the gateway"""
        resp = requests.get(wazigate_url + '/device/id')
        self.assertEqual(resp.status_code, 200)
        self.assertNotEqual(len(resp.text), 0)
        
    def test_get_self(self):
        """ Test get gateway"""
        resp = requests.get(wazigate_url + '/device', cookies={'Token': self.token})
        self.assertEqual(resp.status_code, 200)
        self.assertTrue(resp.json()["id"])
        self.assertTrue(resp.json()["name"])
        self.assertTrue(resp.json()["created"])

    def test_set_get_name(self):
        """ Test set gateway name"""
        resp = requests.post(wazigate_url + '/device/name', json="test" ,cookies={'Token': self.token})
        self.assertEqual(resp.status_code, 200)
        resp = requests.get(wazigate_url + '/device', cookies={'Token': self.token})
        self.assertEqual(resp.json()["name"], "test")


class TestWaziGateDevices(unittest.TestCase):

    token = None
    def setUp(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.token = {"Authorization": "Bearer " + resp.text.strip('"')}

    def test_post_get_delete_devices(self):
        """ Test device creation on the gateway"""

        # Create a new LoRaWAN device on WaziGate
        resp = requests.post(wazigate_url + '/devices', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        print(resp.text)
        
        # Check that it's effectively created
        resp2 = requests.get(wazigate_url + '/devices/' + resp.text, headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        self.assertEqual(resp2.json()["name"], "test")
    
        print(wazigate_url + '/devices/' + resp.text)
        resp3 = requests.delete(wazigate_url + '/devices/' + resp.text, headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        
        resp4 = requests.get(wazigate_url + '/devices/' + resp.text, headers = self.token)
        self.assertEqual(resp4.status_code, 404)
    
    def test_update_name_devices(self):
        """ Test device update name"""

        # Create a new LoRaWAN device on WaziGate
        resp = requests.post(wazigate_url + '/devices', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        
        # Check that it's effectively created
        resp2 = requests.post(wazigate_url + '/devices/' + resp.text + "/name", json="test2", headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        
        resp3 = requests.get(wazigate_url + '/devices/' + resp.text, headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        self.assertEqual(resp3.json()["name"], "test2")


class TestWaziGateSensors(unittest.TestCase):

    token = None
    dev_id = ""
    def setUp(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.token = {"Authorization": "Bearer " + resp.text.strip('"'), 
                      "Content-Type": "text/plain"}

        resp = requests.post(wazigate_url + '/devices', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        self.dev_id = resp.json()
        print(self.dev_id)

    def test_get_sensors(self):
        """ Test get sensors"""
        resp = requests.get(wazigate_url + '/devices/' + self.dev_id + '/sensors', headers = self.token)
        self.assertEqual(resp.status_code, 200)
    
    def test_post_get_delete_sensors(self):
        """ Test post, get and delete sensors"""
        resp = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        
        resp2 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp.text.strip('"'), headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        self.assertEqual(resp2.json()["name"], "test")
        
        resp3 = requests.delete(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp.text.strip('"'), headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        
        resp4 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp.text.strip('"'), headers = self.token)
        self.assertEqual(resp4.status_code, 404)

    def test_sensor_value(self):
        """ Test post and get sensors value"""
        resp = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)

        resp2 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp.text.strip('"') + "/value", json="7.2", headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        
        resp3 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp.text.strip('"') + "/value", headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        self.assertEqual(resp3.json(), "7.2")

    def test_sensor_values(self):
        """ Test post and get sensors values"""
        resp = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)

        resp2 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp.text.strip('"') + "/values", json=[7.2, 7.3], headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        
        resp3 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp.text.strip('"') + "/values", headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        self.assertEqual(len(resp3.json()), 2)

    # Remove any resources that was created
    def tearDown(self):
        resp = requests.delete(wazigate_url + '/devices/' + self.dev_id, headers = self.token)
        self.assertEqual(resp.status_code, 200)

class TestWaziGateActuators(unittest.TestCase):

    token = None
    dev_id = ""
    def setUp(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.token = {"Authorization": "Bearer " + resp.text.strip('"')}

        resp = requests.post(wazigate_url + '/devices', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        self.dev_id = resp.text

    def test_get_sensors(self):
        """ Test get sensors"""
        resp = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators', headers = self.token)
        self.assertEqual(resp.status_code, 200)
    
    def test_post_get_delete_sensors(self):
        """ Test post, get and delete sensors"""
        resp = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        
        resp2 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp.text.strip('"'), headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        self.assertEqual(resp2.json()["name"], "test")
        
        resp3 = requests.delete(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp.text.strip('"'), headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        
        resp4 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp.text.strip('"'), headers = self.token)
        self.assertEqual(resp4.status_code, 404)

    def test_sensor_value(self):
        """ Test post and get sensors value"""
        resp = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)

        resp2 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp.text.strip('"') + "/value", json="7.2", headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        
        resp3 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp.text.strip('"') + "/value", headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        self.assertEqual(resp3.json(), "7.2")

    def test_sensor_values(self):
        """ Test post and get sensors values"""
        resp = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators', json={'name':'test'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)

        resp2 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp.text.strip('"') + "/values", json=[7.2, 7.3], headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        
        resp3 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp.text.strip('"') + "/values", headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        self.assertEqual(len(resp3.json()), 2)

    # Remove any resources that was created
    def tearDown(self):
        resp = requests.delete(wazigate_url + '/devices/' + self.dev_id, headers = self.token)
        self.assertEqual(resp.status_code, 200)

class TestWaziGateClouds(unittest.TestCase):

    def_cloud = {
       "rest": "//api.waziup.io/api/v2",
       "mqtt": "",
       "credentials": {
           "username": "my username",
           "token": "my password"
           }
       }
    token = None
    
    def setUp(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.token = {"Authorization": "Bearer " + resp.text.strip('"')}

    def test_post_get_delete_clouds(self):
        """ Test post, get and delete clouds"""
        resp = requests.post(wazigate_url + '/clouds', json=self.def_cloud, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        
        resp2 = requests.get(wazigate_url + '/clouds/' + resp.text, headers = self.token)
        self.assertEqual(resp2.status_code, 200)
        
        resp3 = requests.delete(wazigate_url + '/clouds/' + resp.text, headers = self.token)
        self.assertEqual(resp3.status_code, 200)
        
        resp4 = requests.get(wazigate_url + '/clouds/' + resp.text, headers = self.token)
        self.assertEqual(resp4.status_code, 404)

    def test_events_clouds(self):
        """ Test clouds events"""
        resp = requests.post(wazigate_url + '/clouds', json=self.def_cloud, headers = self.token)
        self.assertEqual(resp.status_code, 200)
       
        # Try to start the sync with wrong password
        resp2 = requests.post(wazigate_url + '/clouds/' + resp.text + "/paused", json=False, headers = self.token)
        self.assertEqual(resp2.status_code, 200)
       
        time.sleep(1)
        # That should result in an error message in the events
        resp3 = requests.get(wazigate_url + '/clouds/' + resp.text + "/events", headers = self.token)
        self.assertEqual(resp3.json()[0]['code'], 401)
        
        resp4 = requests.delete(wazigate_url + '/clouds/' + resp.text, headers = self.token)
        self.assertEqual(resp4.status_code, 200)
        

if __name__ == "__main__":
    with open('results.xml', 'wb') as output:
        unittest.main(testRunner=xmlrunner.XMLTestRunner(output=output, verbosity=2),
                      failfast=False, 
                      buffer=False, 
                      catchbreak=False)

