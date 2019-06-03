<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');

$conf	= callAPI( 'system/conf');
$ap		= callAPI( 'system/wifi/ap');

$maxAddr = 255;

/*------------*/

$templateData = array(

	'icon'	=>	$pageIcon,
	'title'	=>	$lang['AdvanceConfTitle'],
	'msgDiv'=>	'gw_config_msg',
	'tabs'	=>	array(
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['Radio'],
			'active'	=>	true,
			'notes'		=>	$lang['Notes_AdvanceConf_Radio'],
			'content'	=>	array(
				array( 
						$lang['LoraMode'], 
						editText( array( 
									'id'		=> 'mode',
									'pholder'	=> '',
									//'note'		=> $lang['LoraMode'],
									'type'		=> 'select',
									'source'	=> array(1=>1, 2=>2, 3=>3, 4=>4, 5=>5, 6=>6, 7=>7, 8=>8, 9=>9, 10=>10),
									'value'		=> $conf['radio_conf']['mode'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'radio_conf'),
						)
					)
				),
								
				array( $lang['RadioFreq']	, editRadioFreq( true)),
			),
		),
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['Gateway'],
			'active'	=>	false,
			'notes'		=>	$lang['Notes_AdvanceConf_Gateway'],
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
				
				array( $lang['Encryption']	, 
						editEnabled( array( 
									'id'		=> 'aes',
									'value'		=> $conf['gateway_conf']['aes'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'gateway_conf'),
							)
						)
					),
				
				array( $lang['GPScoordinates']	, 	editGPScoordinates()),

				array( $lang['RawFormat']	, 
						editEnabled( array( 
									'id'		=> 'raw',
									'value'		=> $conf['gateway_conf']['raw'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'gateway_conf'),
							)
						)
					),
					
				array( $lang['wappkey']	, 
						editEnabled( array( 
									'id'		=> 'wappkey',
									'value'		=> $conf['gateway_conf']['wappkey'],
									'params'	=>	array( 'cfg' => 'system/conf', 'conf_node' => 'gateway_conf'),
							)
						)
					),
			),
		),

		/*-----------*/		
		
		array(
			'title'		=>	'Accesss Point',
			'active'	=>	false,
			'notes'		=>	$lang['Notes_AP'],
			'content'	=>	array(

					array(	$lang['SSID'], 
							editText( array(
									'id'		=> 'SSID',
									'label'		=> $lang['SSID'],
									'pholder'	=> $ap['SSID'],
									'note'		=> $lang['APSSIDNote'],
									'value'		=> $ap['SSID'],
									'params'	=>	array( 'cfg' => 'system/wifi/ap'),
							)
						)
					),

					array(	$lang['Password'], 
							editText( array(
									'id'		=> 'password',
									'label'		=> $lang['Password'],
									'pholder'	=> $ap['password'],
									//'note'		=> $lang['APSSIDNote'],
									'value'		=> $ap['password'],
									'params'	=>	array( 'cfg' => 'system/wifi/ap'),
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

/*------------*/

function editLoraMode()
{
	global $_cfg, $conf, $lang;

	$out = '<button id="btn_edit_mode" type="button" class="btn btn-primary"><span class="fa fa-edit"></span></button></td>
		<td id="td_edit_mode">
	    	<div id="div_mode_select" class="form-group">
        		<label>'. $lang['SelectAmode'] .'</label>
        		<select id="mode_select" class="form-control">';
					for( $i = 1; $i <= 10; $i++)
					{
						$selected = $i == $conf['radio_conf']['mode'] ? 'selected="selected"' : '';
						$out .= '<option '. $selected .' value='. $i .'>'. $i .'</option>';
					}

       			$out .= '</select>
    		</div>
    	</td> 
	    <td id="mode_submit" align="right">
	    	<button id="btn_edit_mode" type="submit" class="btn btn-primary">
	    		'. $lang['Submit'] .' <span class="fa fa-arrow-right"></span>
	    	</button>';

	return $out;
}

/*--------------------*/

function editGPScoordinates()
{
	global $_cfg, $conf, $lang;
	return '<button id="btn_edit_gw_position" type="button" class="btn btn-primary">
   				<span class="fa fa-edit"></span>
   			</button>
   		</td>
   	</tr>
   	<tr>
   		<td id="td_edit_gw_position">
   			<div id="div_select_format_position" class="btn-group" data-toggle="buttons">
   				<div id="div_update_format_position" class="form-group">
            		<input type="radio" name="optionsRadios" id="format_dd" value="dd" /> 
	   				<label style="cursor: pointer;" for="format_dd">
		        		Decimal degree
		    		</label>
        		<br />
            		<input type="radio" name="optionsRadios" id="format_dms" value="dms" /> 
		    		<label style="cursor: pointer;" for="format_dms">
		        		Degree, minute, second
		    		</label>
        		</div>
<div id="div_info_format" class="alert alert-danger"></div>
   			</div>
   		</td>
   		<td id="td_format_position_dd">
   			<div id="div_update_dd_position" class="form-group">
   				<div class="radio">
   				<label>Latitude</label>
   				<input id="latitude_dd_input" class="form-control" placeholder="43.2951" name="latitude" type="number_dd" value=""  autofocus>
   				</br>
   				<label>Longitude</label>
   				<input id="longitude_dd_input" class="form-control" placeholder="-0.3707970000000387" name="longitude_dd" type="number" value="" >
 				</br>		
 				</div>	
   			</div>
			
   		</td>
   		<td id="td_format_position_dms">
   			<div id="div_update_dms_position" class="form-group">				
   				<label>Latitude</label>
   				<div class="radio" align="left">
   				<fieldset id="latitude_group" >	
   					<label>
   					<input type="radio" name="latitude_group" id="latitude_north" value="N" checked>N
   					</label>
   					<label>
   					<input type="radio" name="latitude_group" id="latitude_south" value="S" >S
   					</label>
   					</br>
   				</fieldset>
   				</div>
   				<input id="latitude_degree_input" class="form-control" placeholder="43" name="latitude_degree" type="number" value="">
   				<input id="latitude_minute_input" class="form-control" placeholder="17" name="latitude_minute" type="number" value="">
   				<input id="latitude_second_input" class="form-control" placeholder="42.36" name="latitude_second" type="number" value="">
   				</br>			   			
   				<label>Longitude</label>
   				<div class="radio" align="left" >
   				<fieldset id="longitude_group">	
   					<label>
   					<input type="radio" name="longitude_group" id="longitude_east" value="E" checked>E
   					</label>
   					<label>
   					<input type="radio" name="longitude_group" id="latitude_west" value="W" >W
   					</label>
   					</br>
   				</fieldset>
   				</div>
   				<input id="longitude_degree_input" class="form-control" placeholder="0" name="longitude_degree" type="number" value="">
   				<input id="longitude_minute_input" class="form-control" placeholder="22" name="longitude_minute" type="number" value="">
   				<input id="longitude_second_input" class="form-control" placeholder="14.869" name="longitude_second" type="number" value="">
   				</br>
   			</div>
   		</td> 
   		<td id="td_submit_position" align="right">
   			<button align="right" id="btn_submit_position" class="btn btn-primary">'. $lang['Submit'] .' 
   			 <span class="fa fa-arrow-right"></span>
   			</button>';
}

/*--------------------*/

?>
