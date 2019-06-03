<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');


$radio_conf= null; $gw_conf= null; $alert_conf = null;
process_gw_conf_json( $radio_conf, $gw_conf, $alert_conf);

$maxAddr = 255;


/*------------*/

$templateData = array(

	'icon'	=>	$pageIcon,
	'title'	=>	$lang['Profile'],
	'msgDiv'=>	'gooz',
	'tabs'	=>	array(
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['Password'],
			'active'	=>	true,
			'notes'		=>	$lang['Notes_Profile'],
			'content'	=>	array(
				array( getProfilePage()),
			),
		),
		
		/*-----------*/
		
	),
);

/*------------*/

require( './inc/template_admin.php');

/*--------------------*/

function getProfilePage()
{
	global $lang;

	return '<form id="profile_form" role="form">
			<fieldset>
				<div class="form-group">
					<label>'. $lang['CurrentUsername'] .'</label>
					<input id="current_username" class="form-control" placeholder="username" name="current_username" type="text" value="" autofocus>
	                        	</div>
<div class="form-group">
					<label>'. $lang['NewUsername'] .'</label>
					<input id="new_username" class="form-control" placeholder="username" name="new_username" type="text" value="" autofocus>
            	</div>
				<div class="form-group">
					<label>'. $lang['CurrentPassword'] .'</label>
					<input id="current_pwd" class="form-control" placeholder="Current password"  name="current_pwd" type="password" value="">
				</div>
<div class="form-group">
					<label>'. $lang['NewPassword'] .'</label>
					<input id="new_pwd" class="form-control" placeholder="New password" name="new_pwd" type="password" value="">
					<label>'. $lang['RepeatNewPassword'] .'</label>
					<input id="new_pwd" class="form-control" placeholder="Repeat New password" name="rep_new_pwd" type="password" value="">
				</div>

				<center>
					<button  type="submit" class="btn btn-primary">'. $lang['Submit'] .'</button>
					<button  id="btn_profile_form_reset" type="reset" class="btn btn-primary">'. $lang['Clear'] .'</button>
				</center> 
			</fieldset>
		</form>
		<br />
		<div class="inline-msg" style="display:none" id="system_msg"></div>';
}

?>
