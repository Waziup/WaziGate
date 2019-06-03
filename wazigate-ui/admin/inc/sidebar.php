<?php

defined( 'IN_WAZIHUB') or die( 'e902!');

/*---------------------------------*/

$pageIcon = '';

/*---------------------------------*/

$menu = array(

	'overview' => array(
		'text'	=> $lang['Overview'],
		'url' 	=> 'overview',
		'icon'	=> 'fa-heartbeat',
		'active'=> $_GET['page'] == 'overview',
	),

	'configurations' => array(
		'text'	=> $lang['Configurations'],
		'url' 	=> '#conf',
		'icon'	=> 'fa-gear', //fa-universal-access 
		'active'=> in_array( $_GET['page'], array( 'basic_config', 'advance_config', 'setup_wizard', 'clouds', 'internet')),
		'sub'	=> array(
				'basic_config' => array(
					'text'	=> $lang['Basic'],
					'url' 	=> 'basic_config',
					'icon'	=> 'fa-plug',
					'active'=> $_GET['page'] == 'basic_config',
				),
				'advance_config' => array(
					'text'	=> $lang['Advance'],
					'url' 	=> 'advance_config',
					'icon'	=> 'fa-linux',
					'active'=> $_GET['page'] == 'advance_config',
				),
				'internet'=> array(
					'text'	=> $lang['InternetConnectivity'],
					'url' 	=> 'internet',
					'icon'	=> 'fa-chain',
					'active'=> $_GET['page'] == 'internet',
				),
				'clouds' => array(
					'text'	=> $lang['Cloud'],
					'url' 	=> 'clouds',
					'icon'	=> 'fa-mixcloud',
					'active'=> $_GET['page'] == 'clouds',
				),
				'setup_wizard' => array(
					'text'	=> $lang['SetupWizard'],
					'url' 	=> 'setup_wizard',
					'icon'	=> 'fa-gears',
					'active'=> $_GET['page'] == 'setup_wizard',
				),
			),
		),

	'maintenance' => array(
		'text'	=> $lang['Maintenance'],
		'url' 	=> '#maintenance',
		'icon'	=> 'fa-wrench',
		'active'=> in_array( $_GET['page'], array( 'test', 'update')),
			'sub'	=> array(
				'test' => array(
					'text'	=> $lang['TestDebug'],
					'url' 	=> 'test',
					'icon'	=> 'fa-stethoscope', //fa-search, fa-bug
					'active'=> $_GET['page'] == 'test',
				),
				'update' => array(
					'text'	=> $lang['Update'],
					'url' 	=> 'update',
					'icon'	=> 'fa-refresh',
					'active'=> $_GET['page'] == 'update',
				),  
			),
		),

	'notifications' => array(
			'text'	=> $lang['Notifications'],
			'url' 	=> 'notifications',
			'icon'	=> 'fa-envelope',
			'active'=> $_GET['page'] == 'notifications',
		),

	'profile' => array(
			'text'	=> $lang['Profile'],
			'url' 	=> 'profile',
			'icon'	=> 'fa-user',
			'active'=> $_GET['page'] == 'profile',
			'show'	=> false,
		),

	'api-docs' => array(
			'text'	=> $lang['APIDocs'],
			'url' 	=> $_cfg['APIServer']['docs'],
			'link'	=> true, #if the URL is external
			'icon'	=> 'fa-question-circle',
			'active'=> false,
		),		
	
	'docs' => array(
			'text'	=> $lang['Documentations'],
			'url' 	=> '../waziup.io/public/documentation/',
			'link'	=> true, #if the URL is external
			'icon'	=> 'fa-question-circle',
			'active'=> false,
		),
);

/*---------------------------------*/
/*
$cssIcons = @file( '/var/www/html/wazigate/admin/tmp/faFontsContent');
foreach( $cssIcons as $icon)
{
	print( "<i class='fa $icon'></i>$icon<br /><br />");
}/**/

/*---------------------------------*/

$listOfPages = array();
function printRecMenu( $menu)
{
	global $listOfPages, $pageIcon;

	foreach( $menu as $key => $item)
	{
		$listOfPages[ $item['url'] ] = 1;
		
		$item['active'] and $pageIcon = $item['icon'];
		if( isset( $item['show']) && !$item['show']) continue;
		
		if( empty( $item['link'])) $item['url'] = '?page='. $item['url'];
		$target = @$item['link'] ? 'target="_blank"' : '';
		
		$active = $item['active'] ? 'active' : '';
		print( "\n<li><a href='{$item['url']}' $target class='$active'><i class='fa {$item['icon']}'></i> {$item['text']}</a>");
		
		if( isset( $item['sub']) && is_array( $item['sub']))
		{ 
			$open = $item['active'] ? 'collapse in' : '';
			$aria = $item['active'] ? "aria-expanded='true'" : '';

			print( "<ul class='nav $open' $aria id='side-menu' style='padding-left: 10px'>");
				
				printRecMenu( $item['sub']);
				
			print( '</ul>');

		}//End of if( isset( $item['sub']) &&...;
		
		print( '</li>');

	}//End of foreach( $menu as $key => $item); 

}//End of function printRecMenu( $menu);

/*---------------------------------*/

?>
<div class="navbar-default sidebar" role="navigation">
    <div class="sidebar-nav navbar-collapse">
        <ul class="nav" id="side-menu">
            
			<?php printRecMenu( $menu); ?>

        </ul>
    </div>
    <!-- /.sidebar-collapse -->
</div>
<!-- /.navbar-static-side -->

<?php

/*---------------------------------*/
//For security reasons:

isset( $listOfPages[ $_GET['page']]) or $_GET['page'] = '';

/*---------------------------------*/
?>
