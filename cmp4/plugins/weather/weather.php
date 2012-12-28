<?

//error_reporting(E_ERROR | E_WARNING | E_PARSE);
error_reporting(0);

//BOM
echo "\xEF\xBB\xBF";

$cmd = $_REQUEST['cmd'];

if ($cmd == 'getpc') {
	$ip = get_client_ip();
	if ($ip == '127.0.0.1' || $ip == 'unknown') {
		$ip = '222.246.129.81';
	}
	$rs = 'http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip='.$ip;
	$js = get_data($rs);
	echo $js;
	
} else if ($cmd == 'getid') {
	$id = $_REQUEST['id'];
	$rs = 'http://m.weather.com.cn/data/'.$id.'.html';
	$js = get_data($rs);
	echo $js;
	
} else if ($cmd == 'getls') {
	$n = $_REQUEST['n'];
	if (empty($n)) {
		$n = '';
	}
	$url = 'http://service.weather.com.cn/plugin/data/city'.$n.'.xml';
	$data = get_data($url);
	$out = array();
	if (!empty($data)) {
		$arr = explode(',', $data);
		foreach ($arr as $a) {
			$b = explode('|', $a);
			array_push($out, $b);
		}
	}
	echo json_encode($out);
}

function get_client_ip(){
   if (getenv('HTTP_CLIENT_IP') && strcasecmp(getenv('HTTP_CLIENT_IP'), 'unknown'))
       $ip = getenv('HTTP_CLIENT_IP');
   else if (getenv('HTTP_X_FORWARDED_FOR') && strcasecmp(getenv('HTTP_X_FORWARDED_FOR'), 'unknown'))
       $ip = getenv('HTTP_X_FORWARDED_FOR');
   else if (getenv('REMOTE_ADDR') && strcasecmp(getenv('REMOTE_ADDR'), 'unknown'))
       $ip = getenv('REMOTE_ADDR');
   else if (isset($_SERVER['REMOTE_ADDR']) && $_SERVER['REMOTE_ADDR'] && strcasecmp($_SERVER['REMOTE_ADDR'], 'unknown'))
       $ip = $_SERVER['REMOTE_ADDR'];
   else
       $ip = 'unknown';
   return($ip);
}


function get_data($url) {
	if(function_exists('file_get_contents')) {
		return file_get_contents($url);
	} else {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0;)');
		curl_setopt ($ch, CURLOPT_URL, $url);
		curl_setopt ($ch, CURLOPT_RETURNTRANSFER, TRUE);
		curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, 1);
		$d = curl_exec($ch);
		curl_close($ch);
		return $d;	
	}
}

?>