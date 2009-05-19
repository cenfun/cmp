<?php

	define('EZSQL_DB_USER', "root");
	define('EZSQL_DB_PASSWORD', "copacast");
	define('EZSQL_DB_NAME', "blog");
	define('EZSQL_DB_HOST', "localhost");


	/**********************************************************************
	*  ezSQL initialisation for mySQL
	*/

	// Include ezSQL core
	include_once "libs/ez_sql_core.php";

	// Include ezSQL database specific component
	include_once "libs/ez_sql_mysql.php";

	// Initialise database object and establish a connection
	// at the same time - db_user / db_password / db_name / db_host
	//$db = new ezSQL_mysql('db_user','db_password','db_name','db_host');
	$db = new ezSQL_mysql(EZSQL_DB_USER, EZSQL_DB_PASSWORD, EZSQL_DB_NAME, EZSQL_DB_HOST);

	/**********************************************************************
	*  ezSQL demo for mySQL database
	*/
	
	include_once "libs/functions.php";
	
?>