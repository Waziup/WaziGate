<?php

return array(

	'LANG'			=>	'fr',
	'TITLE'			=>	'Française (French)',
	'LDIR'			=>	'ltr', // ltr, rtl, auto
	
	'SignInMsg'		=>	'Please Sign In',
	'Login'			=>	'Login',
	'Username'		=>	'Username',
	'Password'		=>	'Password',
	'LoginError'	=>	'Please enter a valid username and password!',

	'AdminPageTitle' 	=>	'WaziGate Administration',
	'OverviewTitle'		=>	'Gateway Overview',
	'CannotDetermined'	=>	'Ne peut être déterminé!',
	'Radio'			=>	'LoRa Radio',
	'Basic'			=>	'Basic',
	'Advance'		=>	'Advanced',
	'Enabled'		=>	'Enabled',
	'Disabled'		=>	'Disabled',
	'Accessible'	=>	'Accessible',
	'NoInternet'	=>	'No Internet!',
	'NotSet'		=>	'Not Set',

	'BasicConfTitle'=>	'Basic Configurations',
	'Gateway'		=>	'Gateway',
	'RadioFreq'		=>	'Radio Frequency',
	'LoraMode'		=>	'LoRa Mode',
	'Encryption'	=>	'LoRa Encryption (AES)',
	'GPScoordinates'=>	'GPS coordinates',
	'SelectAmode'	=>	'Select a mode',
	'GatewayID'		=>	'Gateway ID',
	'MacAddress'	=>	'Mac address',
	'IPaddress'		=>	'IP address',

	'GatewayIDWarning'		=>	'WARNING: the gateway id is normally derived from the MAC address of the gateway. When you run Update/Basic config the gateway id will be automatically determined so it is not recommended to manually edit the gateway id.',
	
	'NewValue'		=>	'New value',
	'Submit'		=>	'Submit',
	'RawFormat'		=>	'Raw format',
	'wappkey'		=>	'Wapp Key',
	'AdvanceConfTitle'		=>	'Advanced Configurations',
	
	'NotifsTitle'	=>	'Notifications',
	'AlertMail'		=>	'Alert Mail',
	'AlertSMS'		=>	'Alert SMS',
	'Activation'	=>	'Activation',
	'MailAccount'	=>	'Mail Account',
	'MailPassword'	=>	'Mail Password',
	'Empty'			=>	'Empty',
	'MailServer'	=>	'Mail Server',
	'MailRecievers'	=>	'Mail Recievers',
	'MailRecieversNote'	=>	'Please enter one email address per line.',

	'Notes_Overview_Basic'		=>	'Notes_Overview_Basic',
	'Notes_Overview_Advance'	=>	'Notes_Overview_Advance',
	'Notes_BasicConf_Radio'		=>	'Notes_BasicConf_Radio',
	'Notes_BasicConf_Gateway'	=>	'Notes_BasicConf_Gateway',
	'Notes_AdvanceConf_Radio'	=>	'Enable the "PA_BOOST" by default. <br />Notes_AdvanceConf_Radio',
	'Notes_AdvanceConf_Gateway'	=>	'Notes_AdvanceConf_Gateway',
	'Notes_Notifs_Mail'			=>	'Notes_Notifs_Mail',
	'Notes_Notifs_SMS'			=>	'Notes_Notifs_SMS',
	'Notes_Test_Downlink'		=>	'Notes_Test_Downlink',
	'Notes_Test_Logs'			=>	'Notes_Test_Logs',
	'Notes_Cloud_Waziup'		=>	'<ul>
										<li>
											The <tt>Username</tt> is your WAZIUP username. <tt>password</tt> is your WAZIUP password. Use <b>only letters and numbers</b> for <tt>username</tt> and <tt>password</tt>. To create an account on the WAZIUP platform, go to <a href="https://dashboard.waziup.io">https://dashboard.waziup.io</a>. 
											<br /> <br /> 
										</li> 
										<li> 
											<tt>visibility</tt> can be set to <tt>private</tt> so that the gateway creates private sensors under the account of the user. Private sensors can only be seen by its owner.
										</li>
										<li>
											<b>Do not use space nor "/"</b> in any of these parameters, use "_" or "-" instead.
										</li>
									</ul>',
	'Notes_SensorsList'			=>	'Notes_SensorsList',
	'Notes_AdvanceConf_Clouds'	=>	'Notes_AdvanceConf_Clouds',
	'Notes_GPSConf_Clouds'		=>	'<ul>
										<li>
											<tt>Active Interval</tt> defines the time window to mark remote GPS devices as active. It is expressed in minutes.<br /><br />
										</li>
										<li>
											<b>Do not use space nor "/"</b> in any of these parameters, use "_" or "-" instead.
										</li>
									</ul>',
	''		=>	'',
	''		=>	'',

	'PinCode'		=>	'Pin Code',
	'PinCode_Note'	=>	'Be sure that you can access to the sim card and thus change the pin code using telephone/smartphone.',
	'SMSRecievers'		=>	'SMS Recievers',
	'SMSRecievers_Note'	=>	'Please enter one phone number per line.',

	'TestDebugTitle'=>	'Test and Debug',
	'DownlinkReq'	=>	'Downlink Request',
	'SysLogs'		=>	'System Logs',
	'Destination'	=>	'Destination',
	'Message'		=>	'Message',
	'Clear'			=>	'Clear',
	'LogsDownload_Note'	=>	'Copy the current post-processing.log file, extract last 500 lines in a separate file and make links below available (right click to download).',
	'LogsDownload_All'	=>	'The entire content of post-processing.log',
	'LogsDownload_500L'	=>	'Last 500 lines of post-processing.log',
	'ClickHere'	=>	'Click Here',

	'Cloud'			=>	'Cloud',
	'Clouds'		=>	'Clouds',
	'CloudTitle'	=>	'Cloud Setup',
	'Domain'		=>	'Domain',
	'Visibility'	=>	'Visibility',
	'PublicVisibility'	=>	'Public Visibility',
	
	'Overview'		=>	'Overview',
	'Configurations'=>	'Configurations',
	'SetupWizard'	=>	'Setup Wizard',
	'Maintenance'	=>	'Maintenance',
	'TestDebug'	=>	'Test & Debug',
	'Update'	=>	'Update',
	'Notifications'		=>	'Notifications',
	'SensorsList'		=>	'Sensors List',
	'SensorsList_Note'	=>	'Add one sensor per line to your list',
	'CloudNoInternet'	=>	'Cloud No Internet',
	'cloudNodeRed'		=>	'Cloud Node Red',
	'CloudGpsFile'		=>	'Cloud Gps File',
	'ActiveInterval'	=>	'Active Interval',
	'ActiveIntervalNote'=>	'Interval in minutes',
	'SMS'				=>	'SMS',
	'CloudMQTT'			=>	'Cloud MQTT',
	
	'SavedSuccess'		=>	'Saved Successfully.',
	'SaveError'			=>	'Error Saving!',
	
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
	''	=>	'',
						
);

?>
