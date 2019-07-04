#!/usr/bin/python
# @author: Moji eskandari@fbk.eu Jun 21th 2019
#
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
PATH	=	os.path.dirname( os.path.abspath( __file__));

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
	
	dres = os.popen( 'df -B 1 /').read().strip();
	device, size, used, available, percent, mountpoint = dres.split("\n")[1].split();
	disk = {
		'device'	:	device, 
		'size'		:	size, 
		'used'		:	used, 
		'available'	:	available, 
		'percent'	:	percent, 
		'mountpoint':	mountpoint
	};

	
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
		'mem_usage'	:	mem_usage,
		
		'disk'	:	disk
	};

	return json.dumps( res), 201;

#------------------------#

@app.route( '/docker/status', methods=['GET'])
def docker_status():
	cmd = 'curl --unix-socket /var/run/docker.sock http://localhost/containers/json?all=true';
	res = os.popen( cmd).read().strip();
	return res, 201;

	#Ref: https://docs.docker.com/engine/api/v1.26/	

#------------------------#

@app.route( '/docker/update/status', methods=['GET'])
def docker_update_status():
	logF = PATH + '/update_log.txt';
	if( os.path.isfile( logF) == False):
		return json.dumps( False), 201;

	try:
		with open( logF) as f:
			log_txt = f.read();
		res = {
			'time'	: time.ctime( os.path.getmtime( logF)),
			'logs'	: log_txt
		};

	except OSError:
		res = 0

	return json.dumps( res), 201;

#------------------------#

@app.route( '/docker/update', methods=['GET', 'PUT', 'POST'])
def docker_full_update():
	cOut = docker_status();
	cList = json.loads( cOut[0]);
	
	updated = False;
	uiAlive = True;
	
	with open( PATH +'/update_log.txt', 'w+') as log:
		log.seek( 0);

		for cItem in cList:
			cName	=	cItem['Names'][0].strip('/');
			cImage	=	cItem['Image'];
			cmd = 'docker pull '+ cImage;
			res = os.popen( cmd).read().strip();
			log.write( res);
			
			#If there is an update, delete the container and reboot it
			if( res.find( "Downloaded") != -1):
				cmd = 'docker stop '+ cName +'; docker kill '+ cName +'; docker rm '+ cName +'; docker rmi -f "'+ cImage +'"';
				res = os.popen( cmd).read().strip();
				log.write( res);
				updated = True;
				if( cName == "wazigate-ui"):
					uiAlive = False;
		log.truncate();

	#Then Reboot it
	if( updated):
		if( uiAlive):
			#Rebooting by the UI
			res = "REBOOT";
			return json.dumps( res), 201;
		else:
			cmd = 'sudo reboot';
			res = os.popen( cmd).read().strip();

	res = "Your gateway is up to date.";
	return json.dumps( res), 201;

#------------------------#

@app.route( '/docker/<cId>/<action>', methods=['POST', 'PUT'])
def docker_action( cId, action):
	cmd = 'curl --no-buffer -XPOST --unix-socket /var/run/docker.sock http://localhost/containers/'+ cId +'/'+ action;
	res = os.popen( cmd).read().strip();
	return res, 201;

#------------------------#

@app.route( '/docker/<cId>/logs', methods=['GET'])
@app.route( '/docker/<cId>/logs/<tail>', methods=['GET'])
def docker_logs( cId, tail = 0):
	tailStrQ = '';
	if( tail != 0):
		tailStrQ = '--tail='+ str( tail);

#	cmd = 'curl --no-buffer --unix-socket /var/run/docker.sock http://localhost/containers/'+ cId +'/logs?stderr=true&timestamps=true&'+ tailStrQ;
	cmd = ['sudo', 'docker', 'logs', tailStrQ, cId];
	proc = subprocess.Popen( cmd, stdout = subprocess.PIPE,	stderr = subprocess.PIPE);
	stdout, stderr = proc.communicate();

	res = stdout + stderr;
	return res, 201;
	#return json.dumps( res, ensure_ascii=False), 201;

#------------------------#

if __name__ == "__main__":
	app.run( host = '0.0.0.0', debug = True, port = 5544);
