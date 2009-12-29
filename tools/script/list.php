<?
header("Content-Type: text/xml");

$rn = chr(13).chr(10);
$list = '<list>'.$rn;
$cats = array("chartlisting", "topiclisting");
foreach ($cats as $cat) {
	$c_url = "http://www.google.cn/music/".$cat."dir?cat=song&output=xml";
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
		$s_url = "http://www.google.cn/music/".$cat."?cat=song&output=xml&q=".urlencode($c_id);
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
			//"http://www.google.cn/music/songstreaming?id=".$s_id."&output=xml&cd=top100%5Fbest%5Fsongs%5Fof%5Fthe%5Fdecade&cad=topic%5Fplayer&
			//sig=5bbfd0e89b532459a4de7a563198dcb5";
			
			$list .= '<m type="1" label="'.htmlspecialchars($s_name).'" src="'.$s_id.'" duration="'.htmlspecialchars($s_duration).'" />'.$rn;
		}
		$list .= '</m>'.$rn;
	}
}

$list .= '</list>';

echo $list;


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