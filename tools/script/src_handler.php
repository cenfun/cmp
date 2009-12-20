<?

$from = urldecode($_REQUEST[from]);

$start = urldecode($_REQUEST[start]);

if ($from == "sina") {
	//http://v.iask.com/v_play.php?vid=27015444
	$vid = urldecode($_REQUEST[vid]);
	if (!empty($vid)) {
		$url = "http://v.iask.com/v_play.php?vid=".$vid;
		$data = file_get_contents($url);
		if ($data) {
			$doc = new DOMDocument();
			$doc->loadXML($data);
			$urls = $doc->getElementsByTagName("url");
			if ($urls) {
				$url = $urls->item(0);
				$src = $url->firstChild->nodeValue;
			}
		}
	}
}


if (!empty($src)) {
	if (!empty($start)) {
		$src = $src."?start=".$start;
	}
	echo $src;
	//header("Content-Type: application/force-download");
	//header("Content-Transfer-Encoding: binary");
	//header("location: $src");
}

?>
