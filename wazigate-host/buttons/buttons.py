#
# @ Moji July 29th 2019
#
#---------------------------------#

WiFi_BTN 			=	6	# PIN #31
WiFi_BTN_COUNTDOWN	=	2	# for n seconds the button needs to be held down to revert the wifi/web ui settings

PWR_BTN 			=	26	# PIN #37
SHUTDOWN_COUNTDOWN	=	2	# for n seconds the button needs to be held down to activate shutdown procedure

#---------------------------------#

import time
import os
import RPi.GPIO as GPIO

#---------------------------------#

PATH = os.path.dirname( os.path.abspath( __file__));

#---------------------------------#

def main():
	
	GPIO.setmode( GPIO.BCM)
	GPIO.setup( WiFi_BTN, GPIO.IN, pull_up_down = GPIO.PUD_DOWN);
	GPIO.setup( PWR_BTN, GPIO.IN, pull_up_down = GPIO.PUD_DOWN);
	#GPIO.add_event_detect( PWR_BTN, GPIO.RISING, callback = handleButtons, bouncetime=100);
	#GPIO.cleanup();
	
	while True:
		
		#-----------------------#
		
		PWR_BTN_Counter = 0;
		while( GPIO.input( PWR_BTN) == 1):
			time.sleep( 1);
			PWR_BTN_Counter += 1;
			if( PWR_BTN_Counter >= SHUTDOWN_COUNTDOWN):
				while( GPIO.input( PWR_BTN) == 1):
					time.sleep( 0.2); #Waiting for the button to be released
				print( "Shutting down the gateway...");
				oledWrite( [ " ", " ", "Shutting down..."]);
				time.sleep( 2);
				oledWrite( [ " ", " "]);
				time.sleep( 2);
				system_shutdown();
		
		#-----------------------#
		
		WiFi_BTN_Counter	=	0;
		WiFi_BTN_Pushed		=	False;	# To call the thing only once while user keeps the button pushed
		while( GPIO.input( WiFi_BTN) == 1):
			time.sleep( 1);
			WiFi_BTN_Counter += 1;
			if( WiFi_BTN_Counter >= WiFi_BTN_COUNTDOWN and not WiFi_BTN_Pushed):
				WiFi_BTN_Pushed = True;
				print( "Reverting the settings...");
				#time.sleep( 1);
				system_revert_settings();
		
		#-----------------------#
		
		time.sleep( 1);
		
#---------------------------------#

def oledWrite( msg):
	try:
		with open( PATH + '/../oled/msg.txt', 'w') as f:
			f.write( os.linesep.join( msg));
	except:
		print( "Error: Cannot write into the OLED buffer!");


#---------------------------------#

def system_shutdown():
	cmd = 'sudo shutdown -h now';
	print( cmd);
	return os.popen( cmd).read();

#---------------------------------#

def system_revert_settings():

	oledWrite( [ "Reverting", " Gateway", " Settings..."]);
	
	cmd = 'sudo bash '+ PATH +'/../start_hotspot.sh';
	print( os.popen( cmd).read());
	
	time.sleep(1);
	
	oledWrite( [ ""]);

	#sudo systemctl stop hostapd

	return res;

#---------------------------------#

def handleButtons( ch):
	
	print( GPIO.input( ch));
	#if( ch)
	print( "Button: "+ str( ch));

#---------------------------------#


#---------------------------------#

if __name__ == "__main__":
	main();

#

#---------------------------------#