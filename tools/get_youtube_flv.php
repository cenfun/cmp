<?php
$url = trim($_REQUEST['url']);
if (strpos($url, 'http://youtube.com/watch?v=') === 0)
{
    $ch = curl_init();
 
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_HEADER, false);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
 
    $info = curl_exec($ch);
 
    $pos1 = strpos($info, "&amp;video_id=", $pos1);
    $pos2 = strpos($info, "&amp;t=", $pos2);
 
    $video_id = substr($info, $pos1 + 10, 11);
    $tag_t = substr($info, $pos2 + 3, 32);
 
    $response  = '';
    $response .= '' . $video_id . '';
    $response .= '' . $tag_t . '';
    $response .= '';
 
    header("Content-type: text/xml");
    echo $response;
 
    curl_close($ch);
} else
{
    die("Wrong URL / Parameters");
}
?>