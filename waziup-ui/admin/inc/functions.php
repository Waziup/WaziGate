<?php

/*-------------------*/

function is_connected(){
	$is_connected = @fopen("http://www.waziup.io:80/","r");
	
	if ($is_connected) {
		//shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh get_git_version");	
	}
	else {
		//shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh no_git_version");
	}
	
	return $is_connected;
}

/*-------------------*/


function low_level_gw_status(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh low_level_gw_status");
}

/*-------------------*/


function gw_new_install(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh install_gw");
}

/*-------------------*/

function gw_full_update(){
	return shell_exec("sudo ".LORA_GATEWAY."/scripts/update_gw.sh");
}

/*-------------------*/

function gw_basic_conf(){
	return shell_exec("sudo ".LORA_GATEWAY."/scripts/basic_config_gw.sh");
}

/*-------------------*/

function gw_update_file($filename_url){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh update_gw_file ".$filename_url);
}

/*-------------------*/

function update_web_admin_interface(){
	return shell_exec("sudo ".LORA_GATEWAY."/gw_web_admin/install.sh");
}

/*-------------------*/

function copy_log_file(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh copy_log_file");
}

/*-------------------*/

function hostapd_conf($ssid, $wpa_passphrase){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh wifi ".escapeshellarg($ssid)." ".escapeshellarg($wpa_passphrase));
}

/*-------------------*/

function wificlient_conf($wificlient_ssid, $wificlient_wpa_passphrase){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh wificlient ".escapeshellarg($wificlient_ssid)." ".escapeshellarg($wificlient_wpa_passphrase));
}

/*-------------------*/

function apmode_conf(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh apmode");
}

/*-------------------*/

function apmodenow_conf(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh apmodenow");
}

/*-------------------*/

function dongle_conf_on(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh dongle_on");
}

/*-------------------*/

function dongle_conf_off(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh dongle_off");
}

/*-------------------*/

function loranga_conf_on(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh loranga_on");
}

/*-------------------*/

function loranga_conf_off(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh loranga_off");
}

/*-------------------*/

function loranga_conf_2G(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh loranga_2G");
}

/*-------------------*/

function loranga_conf_3G(){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh loranga_3G");
}

/*-------------------*/

//module => Key => value 
//radio_conf => ch => -1
function update_gw_conf($module, $key, $value){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh gateway_conf ".$module." ".$key." ".$value);
}

/*-------------------*/

function update_paboost($value) {
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh paboost ".$value);
}

/*-------------------*/

function update_contact_sms($contacts){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh contact_sms ".$contacts);
}

/*-------------------*/

function update_contact_mail($contacts){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh contact_mail ".$contacts);
}

/*-------------------*/

function waziup_key($key_name, $key_value){
	if ($key_name == "service_tree"){	
		if ($key_value != '') {	
			$tree = explode("-", $key_value);
			$key_value = "";
			for($i=0; $i < sizeof($tree); $i++){
				if($tree[$i] != '')
					$key_value .= "\-".$tree[$i];
			}	
		//$key_value = addslashes($key_value);
		}
	}
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh waziup_key ".$key_name." ".$key_value);
}

/*-------------------*/

function waziup_conf($key, $value){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh waziup_conf ".$key." ".$value);	
}

/*-------------------*/

function thingspeak_key($write_key){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh thingspeak_key ".$write_key);
}

/*-------------------*/

function thingspeak_conf($key, $value){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh thingspeak_conf ".$key." ".$value);
}

/*For other clouds***************/
function clouds_conf($key, $value,$conf){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh ".$conf." ".$key." ".$value);
}
/********************************/

/*-------------------*/

function read_gw_conf_json(){
	$json_src = file_get_contents( LORA_GATEWAY.'/gateway_conf.json');
	return json_decode($json_src, true);
}

/*-------------------*/

function read_clouds_json(){
	$json_src = file_get_contents( LORA_GATEWAY.'/clouds.json');
	return json_decode($json_src, true);
}

/*-------------------*/

function read_database_json(){
	$json_src = file_get_contents( getRootDir(). '../database.json');
	return json_decode($json_src, true);
}

/*-------------------*/

function process_gw_conf_json(&$radio_conf, &$gw_conf, &$alert_conf){
	$json_data = read_gw_conf_json();
	if($json_data == null){
		echo "Unable to read gateway_conf.json file </br>";
	}
	else{
		$radio_conf = $json_data['radio_conf'];
		$gw_conf = $json_data['gateway_conf'];
		$alert_conf = $json_data['alert_conf'];
	}
}

/*-------------------*/

function process_clouds_json(&$clouds, &$encrypted_clouds, &$lorawan_encrypted_clouds){
	$json_data = read_clouds_json();
	if($json_data == null){
		echo "Unable to read clouds.json file </br>";
	}
	else{
		$clouds = $json_data['clouds'];
		$encrypted_clouds = $json_data['encrypted_clouds'];
		$lorawan_encrypted_clouds = $json_data['lorawan_encrypted_clouds'];
	}
}

/*-------------------*/

function process_key_clouds(){
	$key_waziup = "/home/pi/lora_gateway/key_WAZIUP.py";
	if(is_file($key_waziup)){	
		return json_decode( exec('python /var/www/html/admin/libs/python/key_clouds.py'), true);
	}
	else{
		return json_decode( exec('python /var/www/html/admin/libs/python/key_thingspeak.py'), true);
	}
}

/*-------------------*/

# Enabled field : true or false
function cloud_status($clouds_arr, $cloud_script){
	$i = 0; $find = false;        							
    while($i < count($clouds_arr) && ! $find)
    {
    	if($clouds_arr[$i]['script'] == $cloud_script)
    	{
			return $clouds_arr[$i]['enabled'];
			if($clouds_arr[$i]['enabled']){
				echo "true"; 
			}
			else {
				echo "false"; 
			}
		}
		$i++;
    }       							
}

/*-------------------*/

function send_downlink($dst, $msg){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh downlink_request ".$dst." ".$msg);
}

/*-------------------*/

function display_array($arr){
	for($i = 0; $i < sizeof($arr); $i++ ){	
		if($i == sizeof($arr)-1)		
			echo $arr[$i];
		else
			echo $arr[$i].", ";
	}
}

/*-------------------*/

function check_login($db_log, $db_pwd, $form_log, $form_pwd){
	return $db_log==$form_log && $db_pwd==$form_pwd;
}

/*-------------------*/

function set_profile($new_username, $new_password){
	return shell_exec("sudo /var/www/html/admin/libs/sh/web_shell_script.sh set_profile ".$new_username." ".$new_password);
}


/*-------------------*/

function printr( $msg, $dump = false)
{
	print( '<pre style="background-color:#EC0;padding:2px;">');
	$dump ? var_dump( @$msg) : print_r( @$msg);
	print( '</pre>');
}

/*-------------------*/

function timer()
{
    return microtime( true);
}

/*-------------------*/

function getRootDir()
{
	return dirname( __FILE__). '/../';
}

/*--------------------------*/

function printEnabled( $val , $enText = 'Enabled', $disText = 'Disabled')
{
	global $lang;
	if( $val) return( '<div class="enabled"><i class="fa fa-check"></i> '. $lang[ $enText ] .'</div>'); 

	return( '<div class="err"><i class="fa fa-remove"></i> '. $lang[ $disText ] .'</div>');
}

/*--------------------------*/


function getGPScoordinates()
{
	global $conf, $_cfg;
	if( empty( $conf)) $conf = callAPI( 'system/conf');

	return '<div id="latitude_value" class="display:inline">
		Latitude : '. $conf['gateway_conf']['ref_latitude'] .'
	</div>
	<div id="longitude_value" class="display:inline">
	 	Longitude : '. $conf['gateway_conf']['ref_longitude'] .'
	</div>';
}

/*----------------*/

function getRadioFreq()
{
	global $conf, $_cfg;
	
	if( empty( $conf)) $conf = callAPI( 'system/conf');
	
	return $conf['radio_conf']['freq'] != -1 ? $_cfg['loraFreqs'][ $conf['radio_conf']['band']] : printEnabled( $conf['radio_conf']['freq'] != -1, 'Accessible', 'NotSet');

}

/*----------------*/

function getLowLevelStatus()
{
	$output = low_level_gw_status();
	if( empty( $output))
		return '<div class="err">NEED TO WORK ON THE API<br /><i class="fa fa-remove"></i> Desynchronization => '.date('Y-m-d H:i:s') .'</div>';

	$date = explode(".", $output );
	return '<i class="fa fa-check"></i> Last low-level gateway status ON:'. $date[0]; 
}

/*--------------------*/

function editEnabled( $field )
{
	global $_cfg, $lang;
	static $counter = 0;

	//isset( $field['id']) 			or $field[ '' ] = '';
	isset( $field['enText'])		or $field[ 'enText' ]	= 'ON';
	isset( $field['disText'])		or $field[ 'disText' ]	= 'OFF';
	isset( $field['value']) 		or $field[ 'value' ]	= false;
	isset( $field['callbackJS']) 	or $field[ 'callbackJS' ]	= '';
	

	if( !empty( $field['source']))
	{
		$field[ 'value' ]	=	@$field['source'][1] == $field[ 'value' ];
		$field['params']	=	array_merge( $field['params'], $field['source']);
	}

	$field['params']['name'] = $field['id'];
	$getQStr = http_build_query( $field['params']);
	
	$htmlId = $field['id'] . ($counter++);
	
	return '<input type="hidden" class="custom-switch" '. ( $field[ 'value' ] ? 'checked' : '') .' name="'. $htmlId .'" id="'. $htmlId .'" data-url="./?'. $getQStr .'" data-textOn="'. $field[ 'enText' ] .'" value="'. $field[ 'value' ] .'" data-textOff="'. $field['disText'] .'" data-trackColorOn="#512DA8" data-trackColorOff="#616161" data-textColorOff="#fff" data-trackBorderColor="#555" />
	<div style="display:none" class="inline-msg" id="'. $htmlId .'_msg"></div>
	<script>function '. $htmlId .'_trigger(){'. $field['callbackJS'] .'}</script>';

}
/*--------------------*/

function editText( $field )
{
	global $_cfg, $lang;
	
	//isset( $field['id']) 		or $field[ '' ] = '';
	isset( $field['pholder'])	or $field[ 'pholder' ]	= '';
	isset( $field['note']) 		or $field[ 'note' ]		= '';
	isset( $field['value']) 	or $field[ 'value' ]	= '';
	isset( $field['type']) 		or $field[ 'type' ]		= 'text';
	isset( $field['source']) 	or $field[ 'source' ]	= '';
	isset( $field['send']) 		or $field[ 'send' ]		= 'auto';
	isset( $field['class']) 	or $field[ 'class' ]	= 'inlineEdit';
	
	isset( $field['cache']) 	or $field[ 'cache' ]	= 'true';

	isset( $field['params'])	or $field[ 'params' ]	= array();
	$getQStr = http_build_query( $field['params']);
	
	if( is_array( $field[ 'source' ]))
	{
		$out = '[';
		
		foreach( $field[ 'source' ] as $k => $v)
		{
			$out .= "{value: '$k', text: '$v'},";
		}
		$out = rtrim( $out, ',');
		$out .= ']';
		$field[ 'source' ] = $out;

	}//End of if( is_array( $field[ 'source' ]));

	return '<div id="div_update_'. $field['id'] .'" class="form-group">
		<a href="#" id="'. $field['id'] .'" class="'. $field['class'] .'" data-pk="1" data-sourceCache="'. $field[ 'cache' ] .'" data-url="./?'. $getQStr .'" data-type="'. $field[ 'type' ] .'" data-placement="right" data-send="'. $field['send'] .'" data-source="'. $field[ 'source' ] .'" data-title="" data-placeholder="'. $field['pholder'] .'">'. $field['value'] .'</a>
		<div style="display:none" class="inline-msg" id="'. $field['id'] .'_msg"></div>
		<p style="display:none" id="'. $field['id'] .'_note">
			<font color="red">
				'. $field['note'] .'
			</font>
		</p>
	</div>
	';
}

/*--------------------*/

function urlLabel( $field )
{
	global $_cfg, $lang;
	static $counter = 0;

	//isset( $field['id'])	or $field[ '' ] = '';
	isset( $field['value'])	or $field[ 'value' ] = '';
	isset( $field['url'])	or $field[ 'url' ] = '';

	return '<a href="#" id="'. $field['id'] .'_label" class="urlLabel" data-url="'. $field[ 'url' ] .'">'. $field['value'] .'</a>';

}

/*--------------------*/

function editRadioFreq( $advance = false)
{
	global $_cfg, $conf, $lang;
	
	if( empty( $conf)) $conf = callAPI( 'system/conf');

	$out = '<div class="form-group">
        		<label>ISM Band</label>
        		<select id="band_freq_select" class="form-control">';

		foreach( $_cfg['loraFreqs'] as $key => $val)
		{
			$selected = $key == $conf['radio_conf']['band'] ? 'selected="selected"' : '';
			$out .= "<option $selected value='$key'>$val</option>";
		}

		$out .=  '</select>
	   			<label style="'. ( $advance ? '' : 'display:none') .'">Frequency</label>
				<select style="'. ( $advance ? '' : 'display:none') .'" id="freq_select" class="form-control">
	   			</select>
			</div>
		<button id="freq_submit" type="submit" class="btn btn-primary">
			'. $lang['Submit'] .'<span class="fa fa-arrow-right"></span>
		</button>
		<script>
			$(function(){
				$("#band_freq_select").trigger("change");
				$("#freq_select").val( "'. $conf['radio_conf']['freq'] .'");
			});
		</script>';
		
		//array( 'cfg' => 'system/conf', 'conf_node' => 'gateway_conf'),

	return $out;
}

/*--------------------*/

function getAllLangs()
{
	$langs = array();
	foreach( glob( getRootDir() . 'lang/*') as $file)
	{
		$lang = require( $file);
		$langs[ basename( $file, '.php')] = $lang['TITLE'];
	}
	return $langs;
}

/*--------------------*/

function getNetwokIFs()
{
	return CallAPI( 'system/wifi/devices');
}

/*--------------------*/

function CallAPI( $name, $data = false, $method = 'GET', $json = true)
{
	global $_cfg;

    $curl = curl_init();
    
    $url = $_cfg['APIServer']['URL'] . $name;
    $data_json = $json ? json_encode( $data) : http_build_query( $data);
    
    //printr( $url);printr( $data_json);

    switch( $method)
    {
        case "POST":
            
			curl_setopt( $curl, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
			curl_setopt( $curl, CURLOPT_POST, 1);
			curl_setopt( $curl, CURLOPT_POSTFIELDS, $data_json);

            break;

        case "PUT":
            curl_setopt( $curl, CURLOPT_PUT, 1);
            curl_setopt( $curl, CURLOPT_POSTFIELDS, $data_json);
            curl_setopt( $curl, CURLOPT_HTTPHEADER, array(
            							'Content-Type: application/json',
            							'Content-Length: '. strlen( $data_json)
            						)
            		);
            
            break;

        default:
            if( $data)
                $url = sprintf( "%s?%s", $url, http_build_query( $data));

    }//End of switch( $method);

    //<!-- Authentication:
    if( !empty( $_cfg['APIServer']['username']))
    {
		curl_setopt( $curl, CURLOPT_HTTPAUTH, CURLAUTH_BASIC);
		curl_setopt( $curl, CURLOPT_USERPWD, $_cfg['APIServer']['username'] .':'. $_cfg['APIServer']['password']);
	}
	
	
    curl_setopt( $curl, CURLOPT_URL, $url);
    curl_setopt( $curl, CURLOPT_RETURNTRANSFER, 1);
	
    $result = curl_exec( $curl);

    curl_close( $curl);

    return json_decode( $result, true);
}

/*--------------------*/

function strbool( $str)
{
	return $str == 'true';
}

/*--------------------*/

//Update the local copy of Waziup.io
function waziDocsUpdateCheck()
{
	global $_cfg;
	$res = array();
	
	$content = file_get_contents( $_cfg['wazidocs']['git']);
	
	preg_match('/(Commits\ on)([^<]+)/', $content, $matches, PREG_OFFSET_CAPTURE);
	$strDate = trim( $matches[2][0]);

	$res['latestVer']	= date( 'Y-m-d', strtotime( $strDate));
	$res['currentVer']	= date( 'Y-m-d', @filectime( getRootDir() .'../waziup.io'));

	if( $res['latestVer'] > $res['currentVer'])
	{
		$res['doUpdate'] = true;
	}
	
	return $res;
}

/*--------------------*/

function waziDocsUpdateDo()
{
	//TODO
	printr( 'TODO....');
	set_time_limit(0);
	printr( shell_exec( 'ls -al'));
}

/*--------------------*/

?>
