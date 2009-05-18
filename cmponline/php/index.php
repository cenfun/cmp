<?php
	require_once("config.php");
	
	
	// Demo of getting a single variable from the db
	// (and using abstracted function sysdate)
	$current_time = $db->get_var("SELECT " . $db->sysdate());
	print "ezSQL demo for mySQL database run @ $current_time";

	// Print out last query and results..
	$db->debug();

	// Get list of tables from current database..
	$my_tables = $db->get_results("SHOW TABLES",ARRAY_N);

	// Print out last query and results..
	$db->debug();

	// Loop through each row of results..
	foreach ( $my_tables as $table )
	{
		// Get results of DESC table..
		$db->get_results("DESC $table[0]");

		// Print out last query and results..
		$db->debug();
	}

?>
hello!