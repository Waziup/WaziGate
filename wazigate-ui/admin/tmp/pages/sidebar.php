<?php

$menu = array(

	'overview' => array(
		'text'	=> 'Overview',
		'url' 	=> 'overview.php',
		'icon'	=> 'fa-heartbeat',
		'active'=> $activeMenu == 'overview',
	),

	'configurations' => array(
		'text'	=> 'Configurations',
		'url' 	=> '#',
		'icon'	=> 'fa-gear', //fa-universal-access 
		'active'=> in_array( $activeMenu, array( 'basic_config', 'advance_config')),
		'sub'	=> array(
				'basic_config' => array(
					'text'	=> 'Basic',
					'url' 	=> 'basic_config.php',
					'icon'	=> 'fa-plug',
					'active'=> $activeMenu == 'basic_config',
				),
				'advance_config' => array(
					'text'	=> 'Advance',
					'url' 	=> 'advance_config.php',
					'icon'	=> 'fa-linux',
					'active'=> $activeMenu == 'advance_config',
				),  
			),
		),

	'maintenance' => array(
		'text'	=> 'Maintenance',
		'url' 	=> '#',
		'icon'	=> 'fa-wrench',
		'active'=> in_array( $activeMenu, array( 'test', 'update')),
			'sub'	=> array(
				'test' => array(
					'text'	=> 'Test & Debug',
					'url' 	=> 'test.php',
					'icon'	=> 'fa-stethoscope', //fa-search, fa-bug
					'active'=> $activeMenu == 'test',
				),
				'update' => array(
					'text'	=> 'Update',
					'url' 	=> 'update.php',
					'icon'	=> 'fa-refresh',
					'active'=> $activeMenu == 'update',
				),  
			),
		),

	'tiz' => array(
			'text'	=> 'Gooz',
			'url' 	=> 'gooz.php',
			'icon'	=> 'fa-tags',
			'active'=> $activeMenu == 'gooz',
		),
);

/*$cssIcons = @file( '/var/www/html/wazigate/admin/faFontsContent');
foreach( $cssIcons as $icon)
{
	print( "<i class='fa $icon'></i>$icon<br /><br />");
}/**/

function printRecMenu( $menu)
{
	global $activeMenu;

	foreach( $menu as $key => $item)
	{
		$active = $item['active'] ? 'active' : '';
		print( "\n<li><a href='{$item['url']}' class='$active'><i class='fa {$item['icon']}'></i> {$item['text']}</a>");
		
		if( isset( $item['sub']) && is_array( $item['sub']))
		{ 
			$open = $item['active'] ? 'collapse in' : '';
			$aria = $item['active'] ? "aria-expanded='true'" : '';

			print( "<ul class='nav $open' $aria id='side-menu' style='padding-left: 10px'>");
				
				printRecMenu( $item['sub']);
				
			print( '</ul>');
		}
		
		print( '</li>');
	}

}

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
