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
from xmlrunner import XMLTestRunner


## Variable declaration

wazidev_sensor_id = 'temperatureSensor_1'
wazidev_sensor_value = 45.7
wazidev_actuator_id = 'act1'
wazidev_actuator_value = json.dumps(True)

wazigate_url = os.environ.get('WAZIGATE_URL', 'http://172.16.11.187/')

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

    def test_set_name(self):
        """ Test set gateway name"""
        resp = requests.post(wazigate_url + '/device/name', json="test" ,cookies={'Token': self.token})
        self.assertEqual(resp.status_code, 200)
        resp = requests.get(wazigate_url + '/device', cookies={'Token': self.token})
        self.assertEqual(resp.json()["name"], "test")

class TestWaziGateDevices(unittest.TestCase):

    token = None
    dev_id = wazigate_device['id']
    def setUp(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.token = {"Authorization": "Bearer " + resp.text.strip('"')}
        
        # Delete test device if exists
        resp = requests.delete(wazigate_url + '/devices/' + self.dev_id, headers = self.token)

    def test_get_device(self):
        """ Test device gateway"""

        # Create a new LoRaWAN device on WaziGate
        resp = requests.get(wazigate_url + '/device', headers = self.token)
        self.assertEqual(resp.status_code, 200)

    def test_create_device_wazigate(self):
        """ Test device creation on the gateway"""

        # Create a new LoRaWAN device on WaziGate
        resp = requests.post(wazigate_url + '/devices', json = wazigate_device, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        
        # Check that it's effectively created
        resp = requests.get(wazigate_url + '/devices/' + self.dev_id, headers = self.token)
        self.assertEqual(resp.status_code, 200)
    
    def test_delete_device_wazigate(self):
        """ Test device deletion on the gateway"""

        # Create a new LoRaWAN device on WaziGate
        resp = requests.post(wazigate_url + '/devices', json = wazigate_device, headers = self.token)
        
        # Delete it 
        resp = requests.delete(wazigate_url + '/devices/' + self.dev_id, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        
        # Check that it's effectively deleted
        resp = requests.get(wazigate_url + '/devices/' + self.dev_id, headers = self.token)
        self.assertEqual(resp.status_code, 404)
    
    # Remove any resources that was created
    def tearDown(self):
        resp = requests.delete(wazigate_url + '/devices/' + self.dev_id, headers = self.token)


if __name__ == "__main__":
    with open('results.xml', 'wb') as output:
        unittest.main(testRunner=xmlrunner.XMLTestRunner(output=output, verbosity=2),
                      failfast=False, 
                      buffer=False, 
                      catchbreak=False)

