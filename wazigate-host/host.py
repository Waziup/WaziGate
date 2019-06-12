#!/usr/bin/python
from flask import Flask
from flask import request
import subprocess
import json
#import ast
import psutil
import time
import os

#------------------------#

#Path to the root
PATH	=	os.path.dirname(os.path.abspath(__file__));

#------------------------#

app = Flask(__name__);
#app = Flask(__name__, static_url_path = PATH + '/docs/');

#------------------------#

@app.route('/')
def index( filename = ''):
	return "Salam Goloooo!"

#------------------------#

@app.route('/hardware/status', methods=['GET'])
def sys_status():
	
	temp	=	os.popen( 'vcgencmd measure_temp | egrep -o \'[0-9]*\.[0-9]*\'').read().strip();
	config	=	os.popen( 'vcgencmd get_config int').read().strip();
	
	#----------#

	clocks = {'arm' : 0, 'core' : 0, 'h264' : 0, 'isp' : 0, 'v3d' : 0, 'uart' : 0, 'pwm' : 0, 'emmc' : 0, 'pixel' : 0, 'vec' : 0, 'hdmi' : 0, 'dpi' : 0};
	for src in clocks:
		rate = os.popen( 'vcgencmd measure_clock '+ src +' | cut -f2 -d"="').read().strip();
		clocks[src] = int(rate) / 1000000; #Calculate in MHz

	#----------#
	
	volts = {'core' : 0, 'sdram_c' : 0, 'sdram_i' : 0, 'sdram_p' : 0};
	for src in volts:
		rate = os.popen( 'vcgencmd measure_volts '+ src +' | egrep -o \'[0-9]*\.[0-9]*\'').read().strip();
		volts[src] = rate;

	#----------#

	mem_alloc = {'arm' : 0, 'gpu' : 0};
	for src in mem_alloc:
		rate = os.popen( 'vcgencmd get_mem '+ src +' | cut -f2 -d"="').read().strip();
		mem_alloc[src] = rate;

	#----------#
	
	cpu_usage = psutil.cpu_percent();
	mem_usage = dict( psutil.virtual_memory()._asdict());
	
	#----------#

	res = {
		'temp'	:	temp,
		'volts'	:	volts,
		'clocks':	clocks,
		'config':	config,
		
		'mem_alloc'	:	mem_alloc,
		'cpu_usage'	:	cpu_usage,
		'mem_usage'	:	mem_usage
	};

	return json.dumps( res), 201;	

#------------------------#


@app.route('/docker/status', methods=['GET'])
def docker_status():
	
	cmd = 'ip route show default | head -n 1 | awk \'/default/ {print $5}\'';
	dev = os.popen( cmd).read().strip();
	
	if( len( dev) == 0):
		return "", 201;
	
	cmd = 'cat /sys/class/net/'+ dev +'/address';
	mac = os.popen( cmd).read().strip();
	
	cmd = 'ip -4 addr show '+ dev +' | grep -oP \'(?<=inet\s)\d+(\.\d+){3}\'';
	ip = os.popen( cmd).read().strip();
	
	res = {
		'ip'	:	ip,
		'dev'	:	dev,
		'mac'	:	mac
	};

	return json.dumps( res), 201;	

#------------------------#

@app.route( '/docker/<cName>logs', methods=['GET'])
def get_logs( cName):
	n = 0;
	if( n > 0):
		cmd = 'tail -n '+ str( n ) +' '+ LOGS_PATH +'/post-processing.log';
	else:
		cmd = 'cat '+ LOGS_PATH +'/post-processing.log';

	return os.popen( cmd).read();
	
#------------------------#

if __name__ == "__main__":
	app.run( host = '0.0.0.0', debug = True, port = 5544);
