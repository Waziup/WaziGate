<?php
include_once '../libs/php/functions.php';

// begin our session
session_start();

// check if the user is logged out
if( @empty( $_SESSION['username']))
{
	header('Location: login.php');
	exit();
}

$clouds = null; $encrypted_clouds= null; $lorawan_encrypted_clouds = null; $key_clouds = null;

process_clouds_json( $clouds, $encrypted_clouds, $lorawan_encrypted_clouds);

$key_clouds = process_key_clouds();

$key_waziup_file = "/home/pi/lora_gateway/key_WAZIUP.py";	
$waziup = is_file($key_waziup_file);

require 'header.php';
?>
        <div id="page-wrapper">
            <div class="row">
                <div class="col-lg-12">
                    <h1 class="page-header">Cloud</h1>
                </div>
            </div>
            <!-- /.row -->
          
            <div class="panel panel-default">
                        <div class="panel-heading">
                          	<div id="cloud_msg"></div>
                        </div>
                        <!-- /.panel-heading -->
                        <div class="panel-body">
                            <!-- Nav tabs -->
                            <ul class="nav nav-pills">
								<li class="active"><a href="#waziup-pills" data-toggle="tab">Cloud WAZIUP</a></li>
								<li><a href="#cloudNoInternet-pills" data-toggle="tab">Cloud No Internet</a>
								</li>
								<li><a href="#cloudGpsFile-pills" data-toggle="tab">Cloud Gps File</a>
								</li>
								<li><a href="#cloudMQTT-pills" data-toggle="tab">Cloud MQTT</a>
								</li>
								<li><a href="#cloudNodeRed-pills" data-toggle="tab">Cloud Node-RED </a>
								</li>
                            </ul>

                            <!-- Tab panes -->
                            <div class="tab-content">
								<div class="tab-pane fade in active" id="waziup-pills">
									<?php require 'waziup.php'; ?>
								</div>
                                <?php require 'cloudNoInternet.php'; ?>
                                <?php require 'cloudGpsFile.php'; ?> 
                                <?php require 'cloudMQTT.php'; ?>
                                <?php require 'cloudNodeRed.php'; ?>
                      			
                                <!-- tab-pane -->  
                        </div>        
                        <!-- /.panel-body -->
                </div>
                <!-- /.panel -->
		</div>
	</div>        
<?php require 'footer.php'; ?>
