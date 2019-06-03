<?php
// unplanned execution path
defined( 'IN_WAZIHUB') or die( 'e902!');

?>
<div id="page-wrapper">
    <div class="row">
        <div class="col-lg-12">
            <h1 class="page-header">
            	<?php print( '<i class="fa '. $templateData['icon'] .'"></i> '. $templateData['title']); ?>
            </h1>
        </div>
    </div>
    <!-- /.row -->
    
    
    
    <div class="panel panel-default">
                <div class="panel-heading">
                   <div id="<?php print( $templateData['msgDiv']); ?>"></div>
                </div>
                
                <!-- /.panel-heading -->
                <div class="panel-body">
                    <!-- Nav tabs -->
                    <ul class="nav nav-pills">
                    
                    	<?php
                    		foreach( $templateData['tabs'] as $tabId => $tab)
                    		{
                    			$active = $tab['active'] ? 'active' : '';
                    			print( "<li class='$active'>
				            				<a href='#tab_$tabId' data-toggle='tab'>
				            					{$tab['title']}
				            				</a>
				            			</li>");
                    		
                    		}//End of foreach( $templateData['tabs'] as ...;
                    	
                    	?>

                    </ul>

                    <!-- Tab panes -->
                    <div class="tab-content">
                    
                    	<?php
                    		foreach( $templateData['tabs'] as $tabId => $tab)
                    		{
                    			//<div id='radio_msg'></div>
                    			$active = $tab['active'] ? 'in active' : '';
                    			print( "<div class='tab-pane fade $active' id='tab_$tabId'>
                    						<br />
                    						
                    						<div class='col-md-10 col-md-offset-0'>
                              					<div class='table-responsive'>
													<table class='table table-striped table-bordered table-hover' style='border-collapse: separate;'>
								  						<thead>
														</thead>
														<tbody>
				            			");
				            			
				            	foreach( $tab['content'] as $row)
				            	{
				            		print( isset( $row['id']) ? "<tr id='tr_{$row['id']}'>" : '<tr>');
				            		unset( $row['id']);

				            		foreach( $row as $item)
				            		{
				            			print( "<td><div>$item</div></td>");

				            		}//End of foreach( $row as $item);
				            		
				            		print( '</tr>');
				            	
				            	}//End of foreach( $tab['content'] as $item => $value);
				            	
								    	print( "</tbody>
									  		</table>
									  		<div class='footnotes'>{$tab['notes']}</div>
									 	</div>
								  </div>
				                </div>");
                    		
                    		}//End of foreach( $templateData['tabs'] as ...;
                    	?>
				</div>
			</div>
        </div>
		<!-- /.panel -->

<?php require( 'footer.php'); ?>
