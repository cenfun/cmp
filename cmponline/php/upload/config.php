<?php
	
	//数据库连接设置======================================================================
	//数据库用户
	define('EZSQL_DB_USER', "root");
	//数据库密码
	define('EZSQL_DB_PASSWORD', "copacast");
	//数据库名
	define('EZSQL_DB_NAME', "cmponline");
	//数据库服务器
	define('EZSQL_DB_HOST', "localhost");
	//====================================================================================

	//数据表前缀
	$table_prefix  = 'cmpo_';
	
	//默认字符编码
	$charset = 'utf-8';
	
	//默认xml生成文件路径
	define('PATH_XML', "xml/");

	//初始化数据库连接====================================================================
	include_once "libs/ez_sql_core.php";
	include_once "libs/ez_sql_mysql.php";
	//
	$db = new ezSQL_mysql(EZSQL_DB_USER, EZSQL_DB_PASSWORD, EZSQL_DB_NAME, EZSQL_DB_HOST);
	//====================================================================================
	
	//函数工具库
	include_once "libs/functions.php";
	
?>