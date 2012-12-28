<?php

//上线模式：不显示任何错误报告
error_reporting(0);

//xxtea算法类
require('xxtea.php');

//密码
$password = "cenfun";

//明文列表地址，随便用个名字，一般加一些随机字符，只要别人猜不到就行了
//注意xml请使用标准的utf-8格式
$list_url = "mylist_2012_abc.xml";

//读取列表内容准备加密，也可以从数据库读取内容
$str = file_get_contents($list_url);

//计算密文
$key = strtoupper(md5(strtoupper(md5('CMP'.$password))));
//echo $key;

//用xxtea算法加密，并输出base64格式的密文
echo base64_encode(xxtea_encrypt($str, $key));

?>