<?

$type = urldecode($_REQUEST[type]);

if ($type == "sina") {

	//http://v.iask.com/v_play.php?vid=27015444
	
	$vid = urldecode($_REQUEST[vid]);
	if (empty($vid)) {
		die();	
	}
	
	//echo $vid;
	
	$url = "http://v.iask.com/v_play.php?vid=".$vid;
	$data = file_get_contents($url);
	
	//echo $data;
	
	$doc = new DOMDocument();
	$doc->loadXML($data);
	$urls = $doc->getElementsByTagName("url");
	$url = $urls->item(0);
	$src = $url->firstChild->nodeValue;
	//echo $src;
}


if ($src) {
	header("Content-Type: application/force-download");
	header("Content-Transfer-Encoding: binary");
	header("location: $src");
}

?>
