<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');

$conf	=	callAPI( 'system/conf');

$maxAddr = 255;

/*------------*/

$templateData = array(

	'icon'	=>	$pageIcon,
	'title'	=>	$lang['BasicConfTitle'],
	'msgDiv'=>	'gw_config_msg',
	'tabs'	=>	array(
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['Radio'],
			'active'	=>	true,
			'notes'		=>	$lang['Notes_BasicConf_Radio'],
			'content'	=>	array(
				array( $lang['RadioFreq'], editRadioFreq()),
			),
		),
		
		/*-----------*/
		
		//Moved to the advanced config
		/*array(
			'title'		=>	$lang['Gateway'],
			'active'	=>	false,
			'notes'		=>	$lang['Notes_BasicConf_Gateway'],
			'content'	=>	array(
				
				array( 
						$lang['GatewayID']	, 
						editText( array( 
									'id'		=> 'gateway_ID',
									'label'		=> $lang['GatewayID'],
									'pholder'	=> $lang['NewValue'],
									'note'		=> $lang['GatewayIDWarning'],
									'value'		=> $conf['gateway_conf']['gateway_ID'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'gateway_conf'),
							)
						)
					),
				
			),
		),/**/

		/*-----------*/
		/*-----------*/
	),
);

/*------------*/

require( './inc/template_admin.php');

/*------------*/


?>
