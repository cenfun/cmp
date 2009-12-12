<?php
//'CMP音乐代理，用于实现Flash跨域读取信息,以及突破防盗链
//注意：本程序为php版，您的空间必须支持php，使用过多将会加重服务器负担

$url = $_GET["url"];
$referer = $_GET["referer"];

if($url){

	$path_parts = pathinfo($url);
	$filename = $path_parts["basename"];

	header("Content-Type: application/force-download");
	header("Content-Disposition: attachment; filename=$filename");
	header("Content-Transfer-Encoding: binary");
	
	$str = "Referer: $referer";
	$context = array('http' => array ('header'=> $str));
	$xcontext = stream_context_create($context);
	
	$sFile = file_get_contents($url,false,$xcontext);
	
	if($sFile){
		echo $sFile;
	}else{
		header("location:$url");
	}
}

?>