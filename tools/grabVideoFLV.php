<?php
// Youtube FLV Fetcher
// Responds to both HTTP GET and POST requests
// Author: Abdul Qabiz (abdul dot qabiz at gmail dot com)
//
// Description:Gets the path of FLV from YouTube URL
// Is it a POST or a GET?
if (isset($_GET['url']))
{
$url = $_GET['url'];
$start = $_REQUEST['start'];
$v = $url;
$v = preg_split ("/\?v=/", $v);
//youtube video-id
$v = $v[1];
//hardcoding URL here, couldn't figure how to make CURL follow 303 redirection
//seems something wrong with libCurl or my knowledge...
$url = "http://www.youtube.com/watch?v=" . $v;
//Start the Curl session
$session = curl_init();
curl_setopt ($session, CURLOPT_URL, $url);
//you might want to turn it to false, in case you want
//to content to client (flash etc).
curl_setopt($session, CURLOPT_HEADER, true);
//not working for me :(
curl_setopt($session, CURLOPT_FOLLOWLOCATION, true);
//curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($session, CURLOPT_RETURNTRANSFER, true);
// Make the call
$response = curl_exec($session);
//echo $response;
if (preg_match_all("/&t=[^&]*/", $response, $matches))
{
$t = $matches[0][0];
$t = preg_split("/=/", $t);
//youtube t param
$t = $t[1];
//construct the flv-url
$youtubeVideoPath = "http://www.youtube.com/get_video?video_id=" . $v . "&start=".$start."&t=".$t;
//echo $youtubeVideoPath;
//redirect to flv - you can replace this code with echo/print
//to return the path to client (browser/flash)
header ("Location: $youtubeVideoPath");
}
else
{
echo "null";
}
curl_close($session);
}
else
{
echo "No YouTube URL to process";
}
?>
