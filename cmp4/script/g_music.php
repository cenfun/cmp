<?

$serverUrl = "http://www.google.cn/music/";
$hashKey = "c51181b7f9bfce1ac742ed8b4a1ae4ed";

$op = $_REQUEST[op];
$id = $_REQUEST[id];
if ($op == "src") {
	makeSrc($id);
} elseif ($op == "lrc") {
	makeLrc($id);
} else {
	makeList();	
}

function makeList() {
	global $serverUrl;
	$rn = chr(13).chr(10);
	$list = '<list>'.$rn;
	$cats = array("chartlisting", "topiclisting");
	foreach ($cats as $cat) {
		$c_url = $serverUrl.$cat."dir?cat=song&output=xml";
		$c_str = getContents($c_url);
		$c_doc = new DOMDocument();
		@$c_doc->loadXML($c_str);
		$nodes = $c_doc->getElementsByTagName("node");
		if ($nodes->length == 0) {
			continue;
		}
		foreach ($nodes as $node) {
			$c_name = getNodeValue($node, "name");
			$list .= '<m label="'.htmlspecialchars($c_name).'">'.$rn;
			$c_id = getNodeValue($node, "id");
			$s_url = $serverUrl.$cat."?cat=song&output=xml&q=".urlencode($c_id);
			$s_str = getContents($s_url);
			$s_doc = new DOMDocument();
			@$s_doc->loadXML($s_str);
			$songs = $s_doc->getElementsByTagName("song");
			if ($songs->length == 0) {
				$list .= '</m>'.$rn;
				continue;
			}
			foreach ($songs as $song) {
				$s_id = getNodeValue($song, "id");
				$s_name = getNodeValue($song, "name");
				$s_artist = getNodeValue($song, "artist");
				$s_duration = (int) getNodeValue($song, "duration");
				$list .= '<m type="1" id="'.$s_id.'" label="'.htmlspecialchars($s_artist." - ".$s_name).'" duration="'.htmlspecialchars($s_duration).'" />'.$rn;
			}
			$list .= '</m>'.$rn;
		}
	}
	$list .= '</list>';
	header("Content-Type: text/xml");
	echo $list;
}

function makeSrc($id) {
	if (empty($id)) {
		return;	
	}
	$src = getSongInfo($id, "songUrl");
	if ($src) {
		header("location: $src");
	}
}

function makeLrc($id) {
	if (empty($id)) {
		return;	
	}
	$lrc = getSongInfo($id, "lyricsUrl");
	if ($lrc) {
		$data = getContents($lrc);
		echo $data;
	}
}

function getSongInfo($id, $name) {
	global $hashKey,$serverUrl;
	$sig = md5($hashKey.$id);
	$url = $serverUrl."songstreaming?id=".$id."&output=xml&sig=".$sig;
	$str = getContents($url);
	$doc = new DOMDocument();
	@$doc->loadXML($str);
	$v = $doc->getElementsByTagName($name);
	if ($v->length == 0) {
		return;	
	}
	return $v->item(0)->nodeValue;
}

function getNodeValue($node, $name) {
	return $node->getElementsByTagName($name)->item(0)->nodeValue;
}
function getContents($url) {
	$ch = curl_init();
	$timeout = 1;
	curl_setopt ($ch, CURLOPT_URL, $url);
	curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt ($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
	$file_contents = curl_exec($ch);
	curl_close($ch);
	return $file_contents;
}

?> 