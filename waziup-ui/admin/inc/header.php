<?php
	defined( 'IN_WAZIHUB') or die( 'e902!');

?><!DOCTYPE html>
<html lang="<?php print( $lang['LANG']);?>">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title><?php print( $lang['AdminPageTitle']);?></title>
    
	<script src="./style/js/jquery-3.2.1.min.js"></script>
	<script src="./style/js/functions.js"></script> <!-- load our javascript file -->


    <!-- Bootstrap Core CSS -->
    <link href="./style/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

    <!-- MetisMenu CSS -->
    <link href="./style/css/metisMenu.min.css" rel="stylesheet" type="text/css" />

    <!-- Custom CSS -->
    <link href="./style/css/sb-admin-2.css" rel="stylesheet" type="text/css" />

    <!-- Morris Charts CSS -->
    <link href="./style/css/morris.css" rel="stylesheet" type="text/css" />

    <!-- Custom Fonts -->
    <link href="./style/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="./style/js/on-off-switch.js"></script>
    <script type="text/javascript" src="./style/js/on-off-switch-onload.js"></script>
    <link rel="stylesheet" type="text/css" href="./style/css/on-off-switch.css"/>

	
	<script src="./style/js/bootstrap.min.js"></script>  

    <!-- x-editable (bootstrap version) -->
    <link href="./style/css/bootstrap-editable.css" rel="stylesheet"/>
    <script src="./style/js/bootstrap-editable.min.js"></script>
    
	<!-- <link href="./style/css/select2.css" rel="stylesheet" type="text/css"></link>
	<script src="./style/js/select2.js"></script>
	<link href="./style/css/select2-bootstrap.css" rel="stylesheet" type="text/css"></link>	-->

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->
    
    <style type="text/css">
    	
    	.sidebar ul li a.active{
			color: #FFF;
			background-color: #337ab7;
		}
		
		a.active{
			color: #FFF;
			background-color: #337ab7;
			font-weight: bold;
		}
		
		.err{
			font-weight: bold;
			color: #F00;
			background-color: #FFC;
		}
		
		.enabled{
			color: #080;
		}

		div.footnotes{
			border-radius: 10px;
			background: url("./style/img/paper.gif");
			background-position: left top;
			background-repeat: repeat;
			padding: 10px;
			width: 100%;
			height: 100%; 
		}
		div.footnotes:empty { display: none }
		
		ul.wifi li:hover{ display:block; background-color:#EAEAFF;}
		i.wifibar{
			width: 20px;
			height: 20px;
		}
		i#wifibar0{ background: url("./style/img/bars.jpg") no-repeat -112px 0px;}
		i#wifibar1{ background: url("./style/img/bars.jpg") no-repeat -84px 0px;}
		i#wifibar2{ background: url("./style/img/bars.jpg") no-repeat -57px 0px;}
		i#wifibar3{ background: url("./style/img/bars.jpg") no-repeat -29px 0px;}
		i#wifibar4{ background: url("./style/img/bars.jpg") no-repeat -2px 0px;}
		
		div.inline-msg{
			color:#555;
			border-radius:10px;
			font-family:Tahoma,Geneva,Arial,sans-serif;
			font-size:11px;
			padding:10px 10px 10px 36px;
			margin:10px;
			background-color:#e9ffd9;
			border:1px solid #a6ca8a;
		}
		
		div.logs pre{
			color:#FFC;
			border-radius:4px;
			font-family:Courier;
			font-size:16px;
			padding:3px 3px 3px 6px;
			margin:10px;
			background-color:#000;
			border:1px solid #008;
		}
		<?php
			if( $lang['LDIR'] == 'rtl')
			{
				print( '
					body{font-family: none;}
					.navbar-header{ float: right;}
					.navbar-right { float: left !important;}
					.navbar-right .dropdown-menu { right: initial; left: 0; text-align: right;}
					.navbar-top-links .dropdown-user { right: initial; left: 0; text-align: right;}
					/*.sidebar{ margin-right:-35px; width:270px;}*/
					.nav-pills > li {float:right;}
					.col-md-10{ float: right;}
					@media all and (min-width: 700px) {
					  #page-wrapper {margin:0 250px 0 0;}
					}					
				');
			}
		?>
		.on-off-switch{direction: ltr;} /*Needs to be like this always*/

    </style>

	<script>
		$(function(){
			new DG.OnOffSwitchAuto({
					cls:".custom-switch",
					//el:"#'.$field['id'] .'",
					height:25,
					textSizeRatio:0.45,
					listener:function( name, checked){
						var formValues = 'chk=1&name='+ name +'&value='+ (checked * 1);
						$.post( $("#"+ name).attr('data-url'), formValues, function( data){
							$("#"+ name +'_msg').html( data).fadeIn().delay(5000).fadeOut('slow');
							eval( name +'_trigger();');
						});
					}
				});

    		//toggle `popup` / `inline` mode
    		$.fn.editable.defaults.mode = 'inline';
    		$(".inlineEdit").editable({
    			emptytext: '<?php print( $lang["Empty"]); ?>',
    			send: 'auto',
    			success: function(data, config) {
				   if(data) {  //record created, response like {"id": 2}
				       $('#' + $(this).attr('id') + '_msg').html( data).fadeIn().delay(5000).fadeOut('slow');
				   }else{
				   		alert( 'No data');
				   }
			   },

    		});

		    $(".inlineEdit").on( 'shown', function(e, editable){
				$('#' + $(this).attr('id') + '_note').fadeIn();
			});

			$(".urlLabel").click( function(){
				$(this).html('Loading...');
				var id = $(this).attr('id');
				$.get( $(this).attr('data-url'), function( data){
					$("#"+id).html( data);
				});
			});

    	});

	</script>
</head>

<body style="direction: <?php print( $lang['LDIR']); ?>;">
    <div id="wrapper">

        <!-- Navigation -->
        <nav class="navbar navbar-default navbar-static-top" role="navigation" style="margin-bottom: 0; margin-top:-10px;" >
        
            <div class="navbar-header" >
				<a class="navbar-brand" href="index.php"><img src="./style/img/logo.png" style="height:80px" /> </a>
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="sr-only" >Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                
                
            </div>
            <br />
            <!-- /.navbar-header -->

            <ul class="nav navbar-top-links navbar-right">
                <li id="header_msg" class="dropdown"></li>
                
                <?php if( !@empty( $_SESSION['username'])) { ?>

		        	<li class="dropdown"></li>
		            <!-- /.dropdown -->
		            <li class="dropdown">

						<button id="btn_reboot" class="btn btn-primary" data-href="?status=reboot" data-toggle="modal" data-target="#confirm-reboot">
		    				<?php print( $lang['Reboot']); ?>
						</button>
						
						<button id="btn_shutdown" class="btn btn-primary" data-href="?status=shutdown" data-toggle="modal" data-target="#confirm-shutdown">
		    				<?php print( $lang['Shutdown']); ?>
						</button>
		
		        	</li>

            	<?php } //End ?>
            	   
                <!-- /.dropdown -->
                <li class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <?php print( $lang['TITLE']); ?>
                        <font size="4"><i class="fa fa-user fa-language"></i></font>
                    </a>
                    <ul class="dropdown-menu dropdown-user">
                        <!-- <li class="divider"></li> -->
                        <?php
                        	foreach( $allLangs as $key => $val)
                        	{
                        		print( "<li><a href='?lang={$key}'>$val</a></li>");
                        	}
                        ?>
                    </ul>
                    <!-- /.dropdown-user -->
                </li>
                <!-- /.dropdown -->
                
                <?php if( !@empty( $_SESSION['username'])) { ?>
                
		            <li class="dropdown">
		                <a class="dropdown-toggle" data-toggle="dropdown" href="#">
		                    <i class="fa fa-user fa-fw"></i> <i class="fa fa-caret-down"></i>
		                </a>
		                <ul class="dropdown-menu dropdown-user">
		                	<li><a id="profile" href="?page=profile"><i class="fa fa-user"></i> <?php print( $lang['Profile']); ?></a>
		                    <li class="divider"></li>
		                    <li><a id="logout" href="process.php?logout=true"><i class="fa fa-sign-out fa-fw"></i> <?php print( $lang['Logout']); ?></a>
		                    </li>
		                </ul>
		                <!-- /.dropdown-user -->
		            </li>
                
                <?php } //End ?>
                
            </ul>
            <!-- /.navbar-top-links -->
	</nav>
