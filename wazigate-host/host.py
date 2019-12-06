#!/usr/bin/python
# @author: Moji eskandari@fbk.eu Jul 05th 2019
#
from flask import Flask
from flask import request
import threading
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

@app.route( '/cmd', methods=['POST'])
def execHostCmd():
	try:
		cmd = str( request.data, encoding='utf-8')
		res = os.popen( cmd).read().strip()
		return res, 200
	except:
		return "", 400
	

#------------------------#

@app.route( '/internet', methods=['GET'])
def internetAccessible():
	try:
		#res = urllib.request.urlopen( "https://waziup.io").getcode();
		cmd = 'sudo timeout 3 curl -Is https://waziup.io | head -n 1 | awk \'{print $2}\'';
		res = subprocess.run( cmd, shell=True, check=True, executable='/bin/bash', stdout=subprocess.PIPE);
		rCode = str( res.stdout.strip(), 'utf-8')
		if rCode == "200":
			return "1", 200;
		else:
			return "0", 200;
	except:
		return "", 400;
		
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
def docker_full_update_web():
	docker_full_update();
	#p = Process(target=docker_full_update);
	t = threading.Thread(name='update child procs', target=docker_full_update)
	t.start()

	return json.dumps( " "), 201;

#------#

def docker_full_update():

	cOut = docker_status();
	cList = json.loads( cOut[0]);
	
	updated = False;
	
	logFile = PATH +'/update_log.txt';
	
	oledWrite( [ "", "Updating..." ]);
	with open( logFile, 'w+') as log:
		log.seek( 0);
		log.write( "Updating Started...\n\n");
	
	for cItem in cList:
		cName	=	cItem['Names'][0].strip('/');
		cImage	=	cItem['Image'];
		cImageID=	cItem['ImageID'];
		cmd = 'docker pull "'+ cImage + '"';
		res = os.popen( cmd).read().strip();
		with open( logFile, 'a') as log:
			log.write( res);
		
		#If there is an update, delete the container and reboot it
		if( res.find( "Downloaded newer image") != -1):
			cmd = 'docker stop '+ cName +'; docker kill '+ cName +'; docker rm '+ cName +'; docker rmi -f "'+ cImageID +'"';
			res = os.popen( cmd).read().strip();
			with open( logFile, 'a') as log:
				log.write( res);
			updated = True;

	#Then Reboot it
	if( updated):
		with open( logFile, 'a') as log:
			log.write( "\n\nNew updates downloaded.\nRebooting...");
		cmd = 'sudo reboot';
		oledWrite( [ "", "Update Done.", "Rebooting..."]);
		res = os.popen( cmd).read().strip();
	else:
		oledWrite( [ "", "Updated."]);
		with open( logFile, 'a') as log:
			log.write( "\n\nYour gateway is updated.");

#------------------------#

@app.route( '/system/shutdown/<status>', methods=['PUT', 'POST'])
def system_shutdown( status):
	if( status == 'reboot'):
		oledWrite( [ " ", " ", "Rebooting..."]);
		cmd = 'sudo shutdown -r now';
		#cmd = 'reboot';

	else:
		if( status == 'shutdown'):
			oledWrite( [ " ", " ", "Shutting down..."]);
			cmd = 'sudo shutdown -h now';
		else:
			return 1, 201	
	time.sleep( 2);
	oledWrite( [ " ", " "]);
	time.sleep( 2);
	print( cmd);
	return os.popen( cmd).read();

#---------------------------------#

@app.route( '/docker/<cId>/<action>', methods=['POST', 'PUT'])
def docker_action( cId, action):
	cmd = 'curl --no-buffer -XPOST --unix-socket /var/run/docker.sock http://localhost/containers/'+ cId +'/'+ action;
	res = os.popen( cmd).read().strip();
	return res, 201;

#------------------------#

@app.route( '/docker/<cId>/logs', methods=['GET'])
@app.route( '/docker/<cId>/logs/<tail>', methods=['GET'])
def docker_logs( cId, tail = 0):
	cmd = ['sudo', 'docker', 'logs', '-t', cId];
	if( tail != 0):
		cmd = ['sudo', 'docker', 'logs', '-t', '--tail='+ str( tail), cId];

#	cmd = 'curl --no-buffer --unix-socket /var/run/docker.sock http://localhost/containers/'+ cId +'/logs?stderr=true&timestamps=true&'+ tailStrQ;
	
	proc = subprocess.Popen( cmd, stdout = subprocess.PIPE,	stderr = subprocess.PIPE);
	stdout, stderr = proc.communicate();

	res = stdout + stderr;
	return res, 201;
	#return json.dumps( res, ensure_ascii=False), 201;

#------------------------#

@app.route( '/wifi/mode/wlan', methods=['PUT', 'POST'])
def wifi_mode_wlan():
	
	oledWrite( [ "", "Connecting to", "    WiFi..."]);
	
	cmd = 'sudo bash '+ PATH +'/start_wifi.sh';
	print( os.popen( cmd).read());
	
	time.sleep(1);
	
	oledWrite( [ ""]);
	checkWlanConn();

	return json.dumps( "OK"), 201;

#------------------------#

def oledWrite( msg):
	try:
		with open( PATH + '/oled/msg.txt', 'w') as f:
			f.write( os.linesep.join( msg));
	except:
		print( "Error: Cannot write into the OLED buffer!");


#---------------------------------#

#Check if the GW is in WLAN mode and if it is connected to the given SSID
def checkWlanConn():
	
	#Check if in AP mode
	cmd = 'systemctl is-active --quiet hostapd && echo 1';
	if( os.popen( cmd).read().strip() == '1'):
		system_revert_settings();
		return True;
	
	#In WLAN Mode:
	time.sleep( 3);
	for i in range( 4):
		oledWrite( [ "", "Checking WiFi..."]);
		res = os.popen( 'iwgetid').read().strip();
		if( len( res) > 0):
			oledWrite( [ ""]);
			return True;
		time.sleep( 3);
		oledWrite( [ ""]);
		time.sleep( 2);
	
	#Could no conenct, need to revert to AP setting
	
	print( "Could not connect!\nReverting the settings...");
	oledWrite( [ "Couldn't Connect", "", "Reverting to AP", "   ..."]);
	time.sleep( 2);
	system_revert_settings();
	
	return False;

#---------------------------------#

@app.route( '/wifi/mode/ap', methods=['PUT', 'POST'])
def system_revert_settings():

	oledWrite( [ "Reverting", " Gateway", " Settings..."]);
	
	cmd = 'sudo bash '+ PATH +'/start_hotspot.sh';
	print( os.popen( cmd).read());
	
	time.sleep(1);
	
	oledWrite( [ ""]);

	#sudo systemctl stop hostapd

	return json.dumps( "OK"), 201;

#---------------------------------#

if __name__ == "__main__":
	#Check if the WLan is OK
	if( checkWlanConn()):
		print( "Wlan OK");

	app.run( host = '0.0.0.0', debug = True, port = 5200);

#	from tornado.wsgi import WSGIContainer
#	from tornado.httpserver import HTTPServer
#	from tornado.ioloop import IOLoop
#
#	http_server = HTTPServer( WSGIContainer(app))
#	http_server.listen(5544)
#	http_server.start(0)  # Forks multiple sub-processes
#	IOLoop.instance().start();