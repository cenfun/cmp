<?php

function page_header($cache = true) {
	//get form cache
	if ($cache) {
		
		
		
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="Keywords" content="CMP,Online,CenFun" />
<meta name="Description" content="CMP Online - bbs.cenfun.com" />
<meta name="Copyright" content="2006-2009 Cenfun.Com" />
<title>CMP Online</title>
<link rel="stylesheet" type="text/css" href="css/main.css" />
<script type="text/javascript" src="js/jquery.js"></script>
<script type="text/javascript" src="js/main.js"></script>
</head>
<body>
<div class="header">
  <div class="header_logo"></div>
  <div class="header_menu">
    <div>menu</div>
  </div>
  <div class="header_banner"></div>
</div>
<?
}

function page_cmp($cache = true) {
	global $db;
	if ($cache) {
		
		
		
	}
?>

	
<?	
}


function page_home($cache = true) {
	global $db;
	
	if ($cache) {
		
		
		
	}
	
	$current_time = $db->get_var("SELECT " . $db->sysdate());
	print "ezSQL demo for mySQL database run @ $current_time";
	
	$db->debug();
	
	$my_tables = $db->get_results("SHOW TABLES",ARRAY_N);
	
	$db->debug();
	
	
	if ($my_tables) {
		foreach ( $my_tables as $table ) {
			// Get results of DESC table..
			$db->get_results("DESC $table[0]");
			$db->debug();
		}
	} else {
		echo "数据库没有任何table";	
	}
}



function page_footer($cache = true) {
	if ($cache) {
		
		
		
	}
?>
<div class="footer">
  <div class="footer_banner"></div>
  <div class="footer_copyright">Copyright 2009, CMP Online</div>
  <div class="footer_script"></div>
</div>
</body>
</html>
<?
}

?>