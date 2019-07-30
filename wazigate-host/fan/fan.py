#
# @ Moji July 29th 2019
#
#---------------------------------#

FAN_PIN 		=	5		# PIN #29
TRIGGER_TEMP 	=	62.0	# Trigger the FAN once the CPU temperature goes above this (Celsius)

#---------------------------------#

import time
import os
import RPi.GPIO as GPIO

#---------------------------------#

#PATH = os.path.dirname(os.path.abspath(__file__));

#---------------------------------#

GPIO.setmode( GPIO.BCM)
GPIO.setup( FAN_PIN, GPIO.OUT);
#GPIO.cleanup();

while True:
	temp = os.popen( 'vcgencmd measure_temp | egrep -o \'[0-9]*\.[0-9]*\'').read().strip();
	GPIO.output( FAN_PIN, float( temp) > TRIGGER_TEMP);
	time.sleep( 5);
		
#---------------------------------#