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
import xml.etree.cElementTree as ET
from pathlib import Path

logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
#requests_log.propagate = True

## Variable declaration
try:
     build_nr = int(sys.argv[1])
except:
    build_nr = 4



wazidev_sensor_id = 'temperatureSensor_1'
wazidev_sensor_value = 45.7
wazidev_actuator_id = 'act1'
wazidev_actuator_value = json.dumps(True)

wazigate_ip = os.environ.get('WAZIGATE_IP', '172.16.11.186') #'192.168.188.29')
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

amount_tests = 10000

# later in linked list with testnames, global for now
test_1_time = 0.0
test_2_time = 0.0




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
    
    
# append values in xml file for evaluation of performance metrics over time
def save_values_for_evaluation(time_1,time_2):
    name_of_file = "aggregated_performance_results.xml"
    path_exists = os.path.exists(name_of_file)
    
    if path_exists: #append data
        tree = ET.parse(name_of_file)
        root = tree.getroot()

        current_build = ET.SubElement(root, "build", buildnr=str(build_nr))
        #root.append(current_build)
        ET.SubElement(current_build, "test1", name="test_post_get_delete_devices").text = str(test_1_time)
        ET.SubElement(current_build, "test2", name="test_sensor_and_actuator_value").text = str(test_2_time)
        tree = ET.ElementTree(root)    
        tree.write(name_of_file,encoding = "UTF-8", xml_declaration = True)
    else:
        root = ET.Element("root")
        build = ET.SubElement(root, "build", buildnr=str(build_nr))
    
        ET.SubElement(build, "test1", name="test_post_get_delete_devices").text = str(test_1_time)
        ET.SubElement(build, "test2", name="test_sensor_and_actuator_value").text = str(test_2_time)
    
        tree = ET.ElementTree(root)
        tree.write(name_of_file)
    
    
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
            print("Created device with following ID: " + resp.text)
            
            # Check that it's effectively created
            resp2 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            if evaluate_status_code(self,resp2.status_code,200):
                resp2 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            self.assertEqual(resp2.json()['name'], 'test')
            print("Check for created device: " + wazigate_url + '/devices/' + resp2.text)
            
            # Delete device afterwards
            resp3 = requests.delete(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            if evaluate_status_code(self,resp3.status_code,200):
                resp3 = requests.delete(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            print("Device was deleted if return empty string: " + resp3.text)
           
            # Check that it's effectively deleted
            resp4 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            if evaluate_status_code(self,resp4.status_code,404): # was 404 in function token gets renewed
                resp4 = requests.get(wazigate_url + '/devices/' + current_device_id, headers = self.token)
            print("If device was deleted it should show, that it was not found: " + resp4.text)
                
        end_time = time.time()
        total_time = end_time - start_time
        
        global test_1_time
        test_1_time = total_time
        
        print("test_post_get_delete_devices: Time in total: " + str(total_time) + "sek     Time for one create, check, delete and check: " + str(total_time/amount_tests)+"sek")


class TestWaziGateSensorsAndActuators(unittest.TestCase):
    token = None
    dev_id = "" 

    def setUp(self):
        self.token = get_token()
        
        # Create device to push/get values to/from
        resp = requests.post(wazigate_url + '/devices', json={'name':'test_repeated'}, headers = self.token)
        self.assertEqual(resp.status_code, 200)
        self.dev_id = resp.json()
            
    def test_sensor_and_actuator_value(self): 
        # Create test sensors/actuators to push/get values to/from
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
            print ("Sensor   : Result of posted value: " + str(x) + " Result of gotten value: " + str(resp3.json()))
            
            """ Test post and get actuator value"""
            resp4 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", json=x, headers = self.token)
            if evaluate_status_code(self,resp4.status_code,200):
                resp4 = requests.post(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", json=x, headers = self.token)
            
            
            resp5 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", headers = self.token)
            if evaluate_status_code(self,resp5.status_code,200):
                resp5 = requests.get(wazigate_url + '/devices/' + self.dev_id + '/actuators/' + resp_act.text.strip('"') + "/value", headers = self.token)
                
            # Check equal     
            self.assertEqual(resp5.json(), x)
            print ("Actuator : Result of posted value: " + str(x) + " Result of gotten value: " + str(resp5.json()))
            
        end_time = time.time()
        total_time = end_time - start_time
        
        global test_2_time
        test_2_time = total_time
            
        print("test_sensor_and_actuator_value: Time in total: " + str(total_time) + "sek     Time for post one sensor value, check, post one actuator value and check: " + str(total_time/amount_tests) +"sek")
        

if __name__ == "__main__":
    with open('results_of_repeated_tests.xml', 'wb') as output:
        unittest.main(argv=['first-arg-is-ignored'], exit=False, testRunner=xmlrunner.XMLTestRunner(output=output, verbosity=1),
                      failfast=False, 
                      buffer=False, 
                      catchbreak=False)
    save_values_for_evaluation(test_1_time, test_2_time)