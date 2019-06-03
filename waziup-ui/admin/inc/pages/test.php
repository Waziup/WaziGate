<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');

$conf	= callAPI( 'system/conf');

$maxAddr = 255;

/*------------*/

$templateData = array(

	'icon'	=>	$pageIcon,
	'title'	=>	$lang['TestDebugTitle'],
	'msgDiv'=>	'gw_config_msg',
	'tabs'	=>	array(
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['SysLogs'],
			'active'	=>	true,
			'notes'		=>	$lang['Notes_Test_Logs'],
			'content'	=>	array(
				
				array( logsForm()),
			),
		),
		
		/*-----------*/
		
		array(
			'title'		=>	$lang['DownlinkReq'],
			'active'	=>	false,
			'notes'		=>	$lang['Notes_Test_Downlink'],
			'content'	=>	array(

				array( downlinkReqForm()),
				
			),
		),
	
	),
);

/*------------*/

require( './inc/template_admin.php');

/*------------*/

function downlinkReqForm()
{
	global $lang, $maxAddr;

	return '<form id="downlink_form" role="form">
				<fieldset>
					<div class="form-group">
						<label>'. $lang['Destination'] .'</label>
						<input class="form-control" placeholder="Between 2 and '. $maxAddr .'" name="destination" type="number" value="" min="2" max="'. $maxAddr .'" autofocus />
					</div>
					<div class="form-group">
						<label>'. $lang['Message'] .'</label>
						<input class="form-control" placeholder="'. $lang['Message'] .'" name="message" type="text" value="" autofocus />
					</div>
					
					<center>
						<button  type="submit" class="btn btn-primary">'. $lang['Submit'] .'</button>
						<button  id="btn_downlink_form_reset" type="reset" class="btn btn-primary">'. $lang['Clear'] .'</button>
					</center> 
				</fieldset>
			</form>';

}

/*------------*/

function logsForm()
{
	global $lang;
	
	return '<table class="table table-striped table-bordered table-hover">
		  <thead></thead>
		<tbody>
		   <tr>
		    <td><a href="?get=logs">'. $lang['LogsDownload_All'] .'</a></td>
		   </tr>
		   <tr>
		    <td><a href="javascript:loadLogs(500);">'.  $lang['LogsDownload_500L'] .'</a></td>
		   </tr>
		</tbody>
	  </table>
	  <div class="logs">
	  	<pre id="logsAjx">NA</pre>
	  </div>
		<table class="table table-striped table-bordered table-hover">
		  <thead></thead>
		<tbody>
		   <tr>
		    <td><a href="?get=logs">'. $lang['LogsDownload_All'] .'</a></td>
		   </tr>
		   <tr>
		    <td><a href="javascript:loadLogs(500);">'.  $lang['LogsDownload_500L'] .'</a></td>
		   </tr>
		</tbody>
	  </table>	  
	  <div id="logsDown"></div>
	  <script>
		var autoR = 0;
		function loadLogs(n){
			$("#logsAjx").html( "<p align=\"center\"><img src=\"./style/img/loading_b.gif\" /></p>").fadeIn();
			$.get( "?get=logs&n="+ n, function( data){
				$("#logsAjx").html( data).fadeIn();
				clearTimeout( autoR);
				if( n == 50){ autoR = setTimeout( function(){loadLogs(50)}, 5000);}
				$("html, body").animate({
					  scrollTop: $("#logsDown").offset().top - 100
				}, 1000);
			});
		}
		$(function(){ loadLogs(50);});
	 </script>';
}

/*------------*/

?>
