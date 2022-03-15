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

wazigate_ip = os.environ.get('WAZIGATE_IP', '192.168.188.29')
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
  "password": "raspberry"
}

amount_tests = 1000




# Some helper functions:
    
# Get WaziGate token
def get_token():
    resp = requests.post(wazigate_url + '/auth/token', json = auth) 
    token = {"Authorization": "Bearer " + resp.json()}
    return token
    
# Evaluate status codes
def evaluate_status_code(self,statusCode,expected_statusCode):
    if statusCode != expected_statusCode:
        self.token = get_token()
        print("new token was requested: ", self.token, statusCode)
        return True
    else:
        return False
    
    
# Classes for the tests     

class TestWaziGateDevices(unittest.TestCase):
    token = None
    def setUp(self):
        # Get WaziGate token
        resp = requests.post(wazigate_url + '/auth/token', json = auth) 
        self.token = {"Authorization": "Bearer " + resp.json()}

    def test_post_get_delete_devices(self):
        
        start_time = time.time()
        
        for x in range(amount_tests):
            """ Test device creation on the gateway"""
    
            # Create a new LoRaWAN device on WaziGate
            resp = requests.post(wazigate_url + '/devices', json={'name':'test'}, headers = self.token)
            if evaluate_status_code(self,resp.status_code,200):
                resp = requests.post(wazigate_url + '/devices', json={'name':'test'}, headers = self.token)
            current_device_id = resp.json() 
            print(resp.text)
            
            # Check that it's effectively created
            resp2 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            if evaluate_status_code(self,resp2.status_code,200):
                resp2 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            self.assertEqual(resp2.json()['name'], 'test')
            print(wazigate_url + '/devices/' + resp2.text)
            
            # Delete device afterwards
            resp3 = requests.delete(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            if evaluate_status_code(self,resp3.status_code,200):
                resp3 = requests.delete(wazigate_url + '/devices/' + current_device_id, headers = self.token)
           
            # Check that it's effectively deleted
            resp4 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            if evaluate_status_code(self,resp4.status_code,404): # was 404 in function token gets renewed
                resp4 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
                
        end_time = time.time()
        total_time = end_time - start_time
        
        
        print("test_post_get_delete_devices: Time in total: " + str(total_time) + "sek     Time for one create, check, delete and check: " + str(total_time/amount_tests)+"sek")
            

class TestWaziGateSensorsAndActuators(unittest.TestCase):
    token = None
    dev_id = "" 

    def setUp(self):
        self.token = get_token()

        resp = requests.post(wazigate_url + '/devices', json={'name':'test_repeated'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        self.dev_id = resp.json()
            
    def test_sensor_and_actuator_value(self): 
        # Create test devices to push values to
        resp_sens = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors', json={'name':'test_sensor'}, headers = self.token)
        self.assertEqual(resp_sens.status_code, 200)
        resp_act = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators', json={'name':'test_actuator'}, headers = self.token)
        self.assertEqual(resp_act.status_code, 200)
        
        start_time = time.time()
        
        for x in range(amount_tests):
            """ Test post and get sensors value"""
            resp2 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp_sens.text.strip('"') + "/value", json=x, headers = self.token)
            if evaluate_status_code(self,resp2.status_code,200):
                resp2 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp_sens.text.strip('"') + "/value", json=x, headers = self.token)
            
            
            resp3 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp_sens.text.strip('"') + "/value", headers = self.token)
            if evaluate_status_code(self,resp3.status_code,200):
                resp3 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/sensors/' + resp_sens.text.strip('"') + "/value", headers = self.token)
            
            # Check equal    
            self.assertEqual(resp3.json(), x)
            
            """ Test post and get actuator value"""
            resp4 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", json=x, headers = self.token)
            if evaluate_status_code(self,resp4.status_code,200):
                resp4 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", json=x, headers = self.token)
            
            
            resp5 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", headers = self.token)
            if evaluate_status_code(self,resp5.status_code,200):
                resp5 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", headers = self.token)
                
            # Check equal     
            self.assertEqual(resp5.json(), x)
            
        end_time = time.time()
        total_time = end_time - start_time
            
            
        print("test_sensor_and_actuator_value: Time in total: " + str(total_time) + "sek     Time for post one sensor value, check, post one actuator value and check: " + str(total_time/amount_tests) +"sek")

if __name__ == "__main__":
    with open('results_of_repeated_tests.xml', 'w') as output:
        unittest.main(testRunner=xmlrunner.XMLTestRunner(output=output, verbosity=2),
                      failfast=False, 
                      buffer=False, 
                      catchbreak=False)