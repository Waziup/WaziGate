<?php
	defined( 'IN_WAZIHUB') or die( 'e902!');
?>

        <!-- Reboot dialog --> 
        <div class="modal _fade" id="confirm-reboot" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                    <h4 class="modal-title" id="myModalLabel"><?php print( $lang['ConfirmReboot']);?></h4>
                </div>
                <div class="modal-body">
	                <?php print( $lang['RebootDialog']);?>
                </div>
                <div class="modal-footer">
                    <button id="cancel_reboot" type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                    <button id="ok_reboot" type="button" class="btn btn-danger btn-ok">Reboot</button>
                </div>
            </div>
       </div>
       </div>
       
       <!-- Shutdown dialog --> 
        <div class="modal _fade" id="confirm-shutdown" tabindex="1000" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		    <div class="modal-dialog">
		        <div class="modal-content">
		            <div class="modal-header">
		                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
		                <h4 class="modal-title" id="myModalLabel"><?php print( $lang['ConfirmShutdown']);?></h4>
		            </div>
		            <div class="modal-body">
		                <?php print( $lang['ShutdownDialog']);?>
		            </div>
		            <div class="modal-footer">
		                <button id="cancel_shutdown" type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
		                <button id="ok_shutdown" type="button" class="btn btn-danger btn-ok">Shutdown</button>
		            </div>
		        </div>
		   </div>
       </div>
       
        </div>
        <!-- /#page-wrapper -->             
    </div>
    <!-- /#wrapper -->
    
    <!-- jQuery -->
    <!--<script src="./style/js/jquery.min.js"></script>-->

    <!-- Bootstrap Core JavaScript -->
    <script src="./style/js/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="./style/js/metisMenu.min.js"></script>

    <!-- Morris Charts JavaScript -->
    <script src="./style/js/raphael.min.js"></script>
    <!--
    <script src="../vendor/morrisjs/morris.min.js"></script>
    <script src="../data/morris-data.js"></script>-->

    <!-- Custom Theme JavaScript -->
    <script src="./style/js/sb-admin-2.js"></script>
    <script src="./style/js/jquery.nicelabel.js"></script>

</body>

</html>
