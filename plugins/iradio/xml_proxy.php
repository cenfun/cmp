<?php
//php代理 用于实现Flash跨域读取信息以及突破防盗链
$url = urldecode($_REQUEST["url"]);
if($url){
	$ref = urldecode($_REQUEST["ref"]);
	$str = "Referer: $ref";
	$context = array('http' => array ('header'=> $str));
	$xcontext = stream_context_create($context);
	$data = file_get_contents($url, false, $xcontext);
	echo $data;
}
?>