<?php

//上线模式：不显示任何错误报告
error_reporting(0);

session_start();

if ($_SESSION['founduser']) {
	//已经登录，直接返回列表
	echo getListContent();
} else {
	//如果有帐号密码提供，则进行登录验证
	if ($_POST['username'] && $_POST['password']) {
		//连接到数据库进行帐号密码核对，这里需自行完成
		//此处仅写死用于测试
		if ($_POST['username'] == "cenfun" && $_POST['password'] == "cenfun") {
			//保存用户名到session
			$_SESSION['founduser'] = $_POST['username'];
			//返回列表
			echo getListContent();		
		}	
	}
}

//以上是最简单的用户信息验证，当然你可以整合到你已有的用户系统中
//直接从post里面读取发送的帐号和密码即可：$_POST['username']  $_POST['password']
//如果不输出任何信息到页面，则登录插件判断为登录失败，否则就返回一个正确的列表内容即可

//返回一个用户对应的列表内容
function getListContent() {
	//可以读取数据库，也可以读取一个xml列表
	$str = '<list><m src="music/test.mp3" label="测试" /></list>';
	//直接输出列表字符串
	return $str;
}


?>