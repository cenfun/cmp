<?

$title = urldecode($_REQUEST[title]);
$artist = urldecode($_REQUEST[artist]);

$title = iconv('UTF-8', 'GBK', $title);
$artist = iconv('UTF-8', 'GBK', $artist);

if (empty($artist)) {
	$arr = split("-", $title);
	$size = sizeof($arr);
	if ($size > 1) {
		$artist = trim($arr[0]);
		$title = trim($arr[1]);
	}
}

//echo "artist:".$artist."|title:".$title;

$url = "http://qqmusic.qq.com/fcgi-bin/qm_getLyricId.fcg?name=".$title."&singer=".$artist."&uin=&key=&version=&miniversion=&from=qqplayer";
$data = file_get_contents($url);

$doc = new DOMDocument();
$doc->loadXML($data);
$list = $doc->getElementsByTagName("songinfo");
foreach($list as $song) { 
	$id = $song->getAttribute("id");
	$num = (int) substr($id, -2);
	$url = "http://music.qq.com/miniportal/static/lyric/".$num."/".$id.".xml";
	$data = file_get_contents($url);
	if ($data) {
		//echo $data;
		$xml = simplexml_load_string($data);
		$lrc = (string) $xml;
		$lrc = iconv('UTF-8', 'GBK', $lrc);
		echo $lrc;
		break;
	}
}

?>
