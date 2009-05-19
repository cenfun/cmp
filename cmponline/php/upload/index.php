<?php

//error_reporting(E_ERROR | E_WARNING | E_PARSE);

ob_start();

require_once("config.php");

require_once("template.php");
//user check===========================================
$logged_in = false;





//====================================================
@header('Content-Type: text/html; charset='.$charset);

//====================================================

//user cmp
$cmp = $_REQUEST[cmp];
if (empty($cmp)) {

	//model selection
	$area = $_REQUEST[area];
		
	if($area == "ajax") {
		
		include("ajax.php");
		
	} else {
		
		//UI page
		page_header();
		
		if($area == "account") {
			
			if(!$logged_in) { 
			
				$area = "login"; 
				
			} else {
				
			}
			
		} elseif($area == "userlist") {
			
			
			
		} elseif($area == "login") {
			
			
	
		} else {
			
			page_home();
	
		}
	
		page_footer();
	
	}

} else {
	
	page_cmp();
	
}

ob_flush();

?>