<?php

defined( 'IN_WAZIHUB') or die( 'e902!');

$message = ""; 

$json_data = read_database_json();
$username = $json_data['username'];
$password = "";

// if default settings (i.e. username = admin and password = loragateway), encrypt password
if(check_login($json_data['username'], $json_data['password'], "admin", "loragateway")){
	$password = md5($json_data['password']);
}
else{ // password is already encrypted
	$password = $json_data['password'];
}

// create a connexion attempt session
if(!isset($_SESSION['attempt'])) $_SESSION['attempt'] = 0;

// check if the user is already logged in
if((isset($_SESSION['username'])) && (isset($_SESSION['password']))){
	//$message = 'User is already logged in';
	if(check_login($username, $password, $_SESSION['username'], $_SESSION['password'])){
		header('Location: ./');
		exit();
	}
}

// check that both the username, password have been submitted
if(!isset( $_POST['username'], $_POST['password'])){
    $message = $lang['LoginError'];
}
else{ // isset($_POST['username']) && isset($_POST['password'])
	
	if(!empty($_POST['username']) && !empty($_POST['password'])){

		if(check_login($username, $password, $_POST['username'], md5($_POST['password']))){
			$_SESSION['username'] = $_POST['username'];
			$_SESSION['password'] = md5($_POST['password']);
 
			//header('Location: ./');
			$message = $lang['LoginSuccess'] .'[ <a href="?">'. $lang['Home'] .'</a> ] <script type="text/javascript">window.location.href="?";</script>';
			//exit();
		}
		else{
			$_SESSION['attempt']++;
 
			//header('Location: ./');
			$message = $lang['LoginError'];
			//exit();
 
			//!\ Cette redirection est nécessaire /!\
		}
  	}
}

//$lang['Login']

?><div class="container">
    <div class="row">
        <div class="col-md-4 col-md-offset-4">
            <div class="login-panel panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title"><?php print( $lang['SignInMsg']);?></h3>
                </div>
                <div class="panel-body">
                    <form id="login_form" role="form" method="post">
                        <fieldset>
                            <div class="form-group">
                                <input class="form-control" placeholder="<?php print( $lang['Username']); ?>" name="username" type="text" value="" maxlength="20" autofocus>
                            </div>
                            <div class="form-group">
                                <input class="form-control" placeholder="<?php print( $lang['Password']); ?>" name="password" type="password" maxlength="20" value="">
                            </div>
                           
                            	<button  type="submit" class="btn btn-lg btn-success btn-block"><?php print( $lang['Login']);?></button>
                        </fieldset>
                    </form>
                </div>
            </div>
            <div id="login_form_msg">
            	<?php print( $message);?>
            </div>
        </div>
    </div>
</div>

</div>

<!-- Bootstrap Core JavaScript -->
<script src="./style/js/bootstrap.min.js"></script>
