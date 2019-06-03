<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');

$conf	= callAPI( 'system/conf');

/*------------*/

$templateData = array(

	'icon'	=>	$pageIcon,
	'title'	=>	$lang['NotifsTitle'],
	'msgDiv'=>	'gw_config_msg',
	'tabs'	=>	array(
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['AlertMail'],
			'active'	=>	true,
			'notes'		=>	$lang['Notes_Notifs_Mail'],
			'content'	=>	array(
				array( $lang['Activation']	, 
						editEnabled( array( 
									'id'		=>	'use_mail',
									'value'		=>	$conf['alert_conf']['use_mail'],
									'type'		=>	'email',
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
							)
						)
					),

				array( 
						$lang['MailAccount'], 
						editText( array( 
									'id'		=> 'mail_from',
									'label'		=> $lang['MailAccount'],
									'pholder'	=> $lang['MailAccount'],
									'note'		=> '', //$lang['GatewayIDWarning'],
									'value'		=> $conf['alert_conf']['mail_from'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
						)
					)
				),
				
				array( 
						$lang['MailPassword'], 
						editText( array( 
									'id'		=> 'mail_passwd',
									'label'		=> $lang['MailPassword'],
									'pholder'	=> $lang['MailPassword'],
									'note'		=> '', //$lang['GatewayIDWarning'],
									'value'		=> empty( $conf['alert_conf']['mail_passwd']) ? '' : '*********',
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
						)
					)
				),
				
				array( 
						$lang['MailServer'], 
						editText( array( 
									'id'		=> 'mail_server',
									'label'		=> $lang['MailServer'],
									'pholder'	=> 'smtp.gmail.com for example',
									'note'		=> '', //$lang['GatewayIDWarning'],
									'value'		=> $conf['alert_conf']['mail_server'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
						)
					)
				),

				array( 
						$lang['MailRecievers'], 
						editText( array( 
									'id'		=> 'contact_mail',
									'label'		=> $lang['MailRecievers'],
									'pholder'	=> "email1@example.com\r\n 	email2@example.com",
									'note'		=> $lang['MailRecieversNote'],
									'value'		=> str_replace( ',', "\n", $conf['alert_conf']['contact_mail']),
									'type'		=> 'textarea',
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
						)
					)
				),

			),
		),
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['AlertSMS'],
			'active'	=>	false,
			'notes'		=>	$lang['Notes_Notifs_SMS'],
			'content'	=>	array(
				
				array( $lang['Activation']	, 
						editEnabled( array( 
									'id'		=> 'use_sms',
									'value'		=> $conf['alert_conf']['use_sms'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
							)
						)
					),				
				
				array( 
						$lang['PinCode'], 
						editText( array( 
									'id'		=> 'pin',
									'label'		=> $lang['PinCode'],
									'pholder'	=> '0000',
									'note'		=> $lang['PinCode_Note'],
									'value'		=> $conf['alert_conf']['pin'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
						)
					)
				),
				
				array( 
						$lang['SMSRecievers'], 
						editText( array( 
									'id'		=> 'contact_sms',
									'label'		=> $lang['SMSRecievers'],
									'pholder'	=> "+number_1	\r\n+number_2	\r\n+number_3	\r\n",
									'note'		=> $lang['SMSRecievers_Note'],
									'value'		=> @implode( "\n", $conf['alert_conf']['contact_sms']),
									//'value'		=> str_replace( ',', "\n", $alert_conf['contact_sms']),
									'type'		=> 'textarea',
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'alert_conf'),
						)
					)
				),
				
			),
		),
		
		/*-----------*/
	
	),
);

/*------------*/

require( './inc/template_admin.php');

/*--------------------*/

?>
