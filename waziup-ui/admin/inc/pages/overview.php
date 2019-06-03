<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');

$conf	=	callAPI( 'system/conf');
$net	=	callAPI( 'system/net');

$maxAddr = 255;

/*------------*/

$templateData = array(

	'icon'	=>	$pageIcon,
	'title'	=>	$lang['OverviewTitle'],
	'msgDiv'=>	'gw_config_msg',
	'tabs'	=>	array(
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['Basic'],
			'active'	=>	true,
			'notes'		=>	$lang['Notes_Overview_Basic'],
			'content'	=>	array(

				array( $lang['RadioFreq']	, getRadioFreq()),
				array( $lang['GatewayID']	, $conf['gateway_conf']['gateway_ID']),
				array( $lang['IPaddress']	, $net['ip']),
				array( $lang['MacAddress']	, empty( $net['dev']) ? '' : ($net['dev'] .' [ '. $net['mac'] .' ]')),
				array( 'Waziup.io'			, printEnabled( is_connected(), 'Accessible', 'NoInternet')),
			),
		),
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['Advance'],
			'active'	=>	false,
			'notes'		=>	$lang['Notes_Overview_Advance'],
			'content'	=>	array(
				
				array( $lang['LoraMode']		, 	$conf['radio_conf']['mode']),
				array( $lang['Encryption']		, 	printEnabled( $conf['gateway_conf']['aes'])),
				array( $lang['GPScoordinates']	, 	getGPScoordinates()),
				//array( $lang['CloudMQTT']		, 	printEnabled( cloud_status( $clouds, "python CloudMQTT.py"))),
				array( 'Low-level status ON'	, 	getLowLevelStatus()),
			),
		),

	),
);

/*------------*/

require( './inc/template_admin.php');

?>
