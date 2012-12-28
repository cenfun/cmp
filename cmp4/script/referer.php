<?php

//开发调试模式：显示错误报告，但不显示通知
//error_reporting(E_ERROR | E_WARNING | E_PARSE);
//上线模式：不显示任何错误报告
error_reporting(0);

//要进行判断的网站域名列表
//仅域名，全小写，注意前面不要加http://
//完全匹配，不支持通配符，需要通配符的可自行去写正则支持
$domain_list = array("cenfun.com", "bbs.cenfun.com", "www.cenfun.com");

//以上列表中的域名是否为黑名单，否则为白名单(默认)
//白名单就是只允许这些来源域
//黑名单就是不允许这些来源域
$is_black_list = FALSE;

//是否允许空来源(默认允许)，就是如果来源页为空时，允许通过，否则必须要有正确的来源地址
//比如直接打开没有referer，还有Firefox中，wmp中，可能不一定每次都有referer来源地址
$allow_empty_referer = TRUE;


//回调函数==================================================================

//成功通过验证后要调用的程序，所有要做的事写到这里面
function succeed() {
	
	echo "welcome";
	
}

//错误没有通过验证要调用的程序，比如返回一个错误页面，或返回一个错误信息，或一个含广告的列表
function error() {
	
	echo "error";
	
}


//来源页判断===============================================================
//取得访问来源的地址
$referer = $_SERVER["HTTP_REFERER"];	
if($referer) {
	//解析来源地址
	$refererhost = parse_url($referer);
	//来源地址的主域名
	$host = strtolower($refererhost['host']);
	if($is_black_list) {
		//如果是黑名单
		if (in_array($host, $domain_list)) {
			error();
		} else {
			succeed();
		}
	} else {
		//如果是白名单
		if($host == $_SERVER['HTTP_HOST'] || in_array($host, $domain_list)) {
			succeed();
		} else {
			error();
		}
	}
} else {
	if ($allow_empty_referer) {
		succeed();
	} else {
		error();
	}
}

?>
