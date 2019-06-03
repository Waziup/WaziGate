<?php

//define( 'LORA_GATEWAY', '/home/pi/lora_gateway');
define( 'LORA_GATEWAY', '/var/www/html/wazigate/gw_full_latest');

$_cfg = array(
	'max_login_attempts'	=>	3, // not implemented!
	
	'lang'		=> 'en', //Default language: en, fa, fr, ...
	
	'loraFreqs'	=> array(
		'-1'		=>	'Not Set',
		'433MHz'	=>	'433MHz (Asia)',
		'868MHz'	=>	'868MHz (EU, Africa)',
		'915MHz'	=>	'915MHz (NA, SA, OC)',
	),
	
	'APIServer'		=>	array(
			'URL'	=>	'http://localhost:5000/api/v1/',	// API server URL to communicate with the system functions
			'docs'	=>	'http://'. $_SERVER['SERVER_ADDR'] .':5000/',			// URL to the API documentations
			'username'	=>	'',
			'password'	=>	'',
	),

	'EdgeServer'	=>	array(
			'URL'	=>	'http://localhost:4000/api/v1/',
			'username'	=>	'',
			'password'	=>	'',
	),
	
	'wazidocs'	=> array(
		'git'	=> 'https://github.com/Waziup/waziup.io/commits',
		
	
	),
);



error_reporting( E_ALL); ini_set('display_errors', 1);
//	error_reporting( E_WARNING & E_ERROR);
//	set_time_limit(0);
?>
