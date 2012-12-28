<?

$from = urldecode($_REQUEST[from]);

$start = urldecode($_REQUEST[start]);

session_start();

if ($from == "sina") {
	//http://v.iask.com/v_play.php?vid=27015444
	$vid = urldecode($_REQUEST[vid]);
	if (!empty($vid)) {
		$session_id = "sina_src".$vid;
		$src = $_SESSION[$session_id];
		//echo "session:[".$src."]";
		if (empty($src)) {
			$url = "http://v.iask.com/v_play.php?vid=".$vid;
			$data = file_get_contents($url);
			if ($data) {
				$doc = new DOMDocument();
				$doc->loadXML($data);
				$urls = $doc->getElementsByTagName("url");
				if ($urls) {
					$url = $urls->item(0);
					$src = $url->firstChild->nodeValue;
					$_SESSION[$session_id] = $src;
				}
			}
		}
	}
}

//echo "\n".$src;

if (!empty($src)) {
	if (!empty($start)) {
		$src = $src."?start=".$start;
	}
	header("location: $src");
}

?>
