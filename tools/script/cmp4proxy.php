<?
//保存已经获取地址到session，节约资源
session_start();
//取得来源页地址
$source = urldecode($_REQUEST[source]);
if (empty($source)) {
	exit();	
}
//解析地址
//dirname basename extension filename
$pi = pathinfo($source);
//scheme host user pass path query fragment
$ui = parse_url($source);

//判断来源类型，获取地址
if (strpos($ui["host"], "video.sina.com.cn")) {
	$src = sina(str_replace($pi["extension"], "", $pi["filename"]));
} else if (strpos($ui["host"], "joy.cn")) {
	$src = joy(str_replace($pi["extension"], "", $pi["filename"]));
}
//echo $src;
if (isset($src)) {
	//流下载支持 (注意分字节型和时间型，详情见：http://bbs.cenfun.com/thread-11037-1-1.html)
	$start = $_REQUEST[start];
	if (!empty($start)) {
		$src = $src."?start=".$start;
	}
	//转向，如果有防盗链的，可能转向后的地址是无法连接的，需要做进一步处理，这里省略
	header("HTTP/1.1 303 See Other");
	header("location: $src");
}

//模块函数==============================================================
function get_data($url) {
	if(function_exists('file_get_contents')) {
		return file_get_contents($url);
	}
	//如果空间不支持file_get_contents，请在下面写其他程序抓取
	//比如用curl
}
//标签截取
function str_cut($str, $pre, $end) {
	$pos_pre = strpos($str, $pre) + strlen($pre);
	$str_end = substr($str, $pos_pre);
	$pos_end = strpos($str_end, $end);
	return substr($str, $pos_pre, $pos_end);
}

function sina($id) {
	//首先从session读取缓存
	$session_id = "sina_src".$id;
	//$src = $_SESSION[$session_id];
	//缓存不存在再从网络抓取
	if (empty($src)) {
		list($vid, $uid) = split ('-', $id);
		$url = "http://v.iask.com/v_play.php?vid=".$vid."&uid=".$uid;
		$str = get_data($url);
		if ($str) {
			$src = str_cut($str, "<url><![CDATA[", "]]></url>");
			//保存地址到session
			$_SESSION[$session_id] = $src;
		}
	}
	return $src;
}

function joy($id) {
	$session_id = "joy_src".$id;
	$src = $_SESSION[$session_id];
	if (empty($src)) {
		//注意msxv5v2可能是个验证值，以后可能会变更，将导致无法获取
		$url="http://msx.app.joy.cn/service.php?action=msxv5v2&playertype=joyplayer&videoid=".$id;
		$str = get_data($url);
		if ($str) {
			$s1 = str_cut($str, "<HostPath", "/HostPath>");
			$s11 = str_cut($s1, ">", "<");
			$s2 = str_cut($str, "<Url", "</Url>");
			$s21 = str_cut($s2, "<![CDATA[", "]]>");
			$src = $s11.$s21;
			//echo $src;
			$_SESSION[$session_id] = $src;
		}
	}
	return $src;
}


?>
