<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');

/*------------*/

$wifi	= callAPI( 'system/wifi');
$conf	= callAPI( 'system/conf');

$templateData = array(

	'icon'	=>	$pageIcon,
	'title'	=>	$lang['InternetConnectivity'],
	'msgDiv'=>	'gw_config_msg',
	'tabs'	=>	array(
		
		/*-----------*/

		array(
			'title'		=>	'WiFi',
			'active'	=>	true,
			'notes'		=>	$lang['Notes_Internet'],
			'content'	=>	array(
			

				array(	$lang['Activation']	, 
						editEnabled( array( 
									'id'			=>	'enabled',
									'value'			=>	$wifi['enabled'],
									'params'		=>	array( 'cfg' => 'system/wifi'),
									'callbackJS'	=>	'setTimeout( function(){location.reload();}, 2000);',
							)
						)
					),

				array(	'Waziup.io' , printEnabled( is_connected(), 'Accessible', 'NoInternet')),
				
				array(	$lang['ConnectedWiFiNetwork'], $wifi['ssid'] . ( $wifi['ssid'] == '' ? '' : " ( {$wifi['ip']} )")),
				
				//array( 'NetInterface' , getNetwokIFs()),
				
				array( $lang['WiFiNetwork'], getAjaxWiFiForm())

				),
			),

		/*-----------*/

		array(
			'title'		=>	$lang['Cellular'],
			'active'	=>	false,
			'notes'		=>	$lang['Notes_Cellular'],
			'content'	=>	array(
			
				array(	$lang['3G_boot'], 
						editEnabled( array( 
									'id'			=>	'3G_boot',
									'value'			=>	$conf['cell_conf']['3G_boot'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'cell_conf'),
									#'callbackJS'	=>	'setTimeout( function(){location.reload();}, 2000);',
							)
						)
					),

				array(	$lang['Loragna_boot'], 
						editEnabled( array( 
									'id'			=>	'loragna_boot',
									'value'			=>	$conf['cell_conf']['loragna_boot'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'cell_conf'),
									#'callbackJS'	=>	'setTimeout( function(){location.reload();}, 2000);',
							)
						)
					),

				array(	$lang['Loragna_G'], 
						editEnabled( array( 
									'id'		=>	'loragna_g',
									'value'		=>	$conf['cell_conf']['loragna_g'],
									'source'	=>	array( false => '2G', true => '3G'),
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'cell_conf', 'custom' => 1),
									'enText'	=>	'3G',
									'disText'	=>	'2G',
									#'callbackJS'	=>	'setTimeout( function(){location.reload();}, 2000);',
							)
						)
					),

				),
			),

		/*-----------*/
		
		/*-----------*/
		
		
		
		/*-----------*/	
		
		/*-----------*/
		/*-----------*/
	
	),
);

/*------------*/

require( './inc/template_admin.php');

/*--------------------*/

function getAjaxWiFiForm()
{
	return '<div id="wifiFormAjx"></div>
		<script>
			$(function(){
				$("#wifiFormAjx").html( "<img src=\"./style/img/loading.gif\" /> Scanning for WiFi networks...").fadeIn();
				$.get( "?get=wifiForm", function( data){
					$("#wifiFormAjx").html( data).fadeIn();
				});
			});
		</script>';
}

?>
