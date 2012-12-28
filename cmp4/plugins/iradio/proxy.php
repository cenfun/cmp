<?php
//php proxy
error_reporting(0);

$url = $_REQUEST["url"];

if(!empty($url)){
	$data = get_data($url);
	echo $data;
}

function get_data($url) {
	if(function_exists('file_get_contents')) {
		return file_get_contents($url);
	}
}

?>