<?
/*
lrc_handler.php
歌词自动下载程序
*/
//禁止错误信息
error_reporting(0);
//音乐标题
$title = urldecode($_REQUEST[title]);
//艺术家名称
$artist = urldecode($_REQUEST[artist]);

//由-横杠分解出艺术家和标题
if (empty($artist)) {
	$arr = split("-", $title);
	$size = sizeof($arr);
	if ($size > 1) {
		$artist = trim($arr[0]);
		$title = trim($arr[1]);
	}
}

$lrc = tt($artist, $title);
if (!$lrc) {
	$lrc = qq($artist, $title);
}

if (!$lrc) {
	$lrc = "[ti:歌词未找到]";
}

echo $lrc;


function tt($artist, $title) {
	$s_doc = new DOMDocument();
	$s_doc->load("http://ttlrcct.qianqian.com/dll/lyricsvr.dll?svrlst");
	$s_list = $s_doc->getElementsByTagName("server");
	if ($s_list->length == 0) {
		return;
	}
	$s = $s_list->item(0);
	$s_url = $s->getAttribute("url");
	$l_url = $s_url."?sh?Artist=".tt_code($artist)."&Title=".tt_code($title)."&Flags=0";
	$l_doc = new DOMDocument();
	$l_doc->load($l_url);
	$l_list = $l_doc->getElementsByTagName("lrc");
	if ($l_list->length == 0) {
		return;
	}
	$l = $l_list->item(0);
	$id = $l->getAttribute("id");
	$ar = $l->getAttribute("artist");
	$ti = $l->getAttribute("title");
	$utf8Str = SetToHexString($ar.$ti);  
	$code = getCode($id, $utf8Str);
	$url = $s_url."?dl?Id=".$id."&Code=".$code;
	$data = file_get_contents($url);
	$data = iconv('UTF-8','GBK', $data);
	return $data;
}

function qq($artist, $title) {
	$i_url = "http://qqmusic.qq.com/fcgi-bin/qm_getLyricId.fcg?name=".$title."&singer=".$artist."&from=qqplayer";
	$xmlstring = file_get_contents($i_url);
	$xmlstring = str_replace("gb2312", "gbk", $xmlstring);
	$i_doc = new DOMDocument();
	$i_doc->loadXML($xmlstring);
	$i_list = $i_doc->getElementsByTagName("songinfo");
	if ($i_list->length == 0) {
		return;
	}
	$song = $i_list->item(0);
	$id = $song->getAttribute("id");
	$num = (int) substr($id, -2);
	$l_url = "http://music.qq.com/miniportal/static/lyric/".$num."/".$id.".xml";
	$l_doc = new DOMDocument();
	$l_doc->load($l_url);
	$l_list = $l_doc->getElementsByTagName("lyric");
	if ($l_list->length == 0) {
		return;
	}
	$l = $l_list->item(0);
	$data = $l->firstChild->nodeValue;
	$data = iconv('UTF-8', 'GBK', $data);
	return $data;
}

function getCode($Id, $utf8Str){  
    $Id = (int) $Id;
    $length = strlen($utf8Str) / 2;  
    for($i=0;$i<$length;$i++)  {
        eval('$song['.$i.'] = 0x'.substr($utf8Str,$i*2,2).';');  
	}
    $tmp2=0;  
    $tmp3=0;   
    $tmp1 = ($Id & 0x0000FF00) >> 8; 
    if ( ($Id & 0x00FF0000) == 0 ) {  
        $tmp3 = 0x000000FF & ~$tmp1; 
    } else {  
        $tmp3 = 0x000000FF & (($Id & 0x00FF0000) >> 16);
    }  
    $tmp3 = $tmp3 | ((0x000000FF & $Id) << 8);
    $tmp3 = $tmp3 << 8;
    $tmp3 = $tmp3 | (0x000000FF & $tmp1);
    $tmp3 = $tmp3 << 8;
    if ( ($Id & 0xFF000000) == 0 ) {  
        $tmp3 = $tmp3 | (0x000000FF & (~$Id));
    } else {  
        $tmp3 = $tmp3 | (0x000000FF & ($Id >> 24));
    }  
    $i=$length-1;  
    while($i >= 0){  
        $char = $song[$i];  
        if($char >= 0x80) $char = $char - 0x100;  
 
        $tmp1 = ($char + $tmp2) & 0x00000000FFFFFFFF;  
        $tmp2 = ($tmp2 << ($i%2 + 4)) & 0x00000000FFFFFFFF;  
        $tmp2 = ($tmp1 + $tmp2) & 0x00000000FFFFFFFF;  
        $i -= 1;  
    }  
    $i=0;  
    $tmp1=0;  
    while($i<=$length-1){  
        $char = $song[$i];  
        if($char >= 128) $char = $char - 256;  
        $tmp7 = ($char + $tmp1) & 0x00000000FFFFFFFF;  
        $tmp1 = ($tmp1 << ($i%2 + 3)) & 0x00000000FFFFFFFF;  
        $tmp1 = ($tmp1 + $tmp7) & 0x00000000FFFFFFFF;  
 
        $i += 1;  
    }
    $t = conv($tmp2 ^ $tmp3);  
    $t = conv(($t+($tmp1 | $Id)));  
    $t = conv(bcmul($t , ($tmp1 | $tmp3)));  
    $t = conv(bcmul($t , ($tmp2 ^ $Id)));  
 
    if(bccomp($t , 2147483648)>0)  
         $t = bcadd($t ,- 4294967296);  
    return $t;
}
function SingleDecToHex($dec){  
    $tmp="";  
    $dec=$dec%16;  
    if($dec<10) return $tmp.$dec;  
    $arr=array("A","B","C","D","E","F");  
    return $tmp.$arr[$dec-10];  
}  
function SetToHexString($str){  
    if(!$str) return false;  
    $tmp="";  
    for($i=0;$i<strlen($str);$i++)  
    {  
        $ord=ord($str[$i]);  
        $tmp.=SingleDecToHex(($ord-$ord%16)/16);  
        $tmp.=SingleDecToHex($ord%16);  
    }  
    return $tmp;  
}  
function tt_code($str){  
        $s=strtolower($str);
        $s=str_replace(" ","",$s);
        $s=str_replace("'","",$s);
        return SetToHexString(iconv('GBK','UTF-16LE',$s));
}  
function conv($num){  
    $tp = bcmod($num,4294967296);  
 
    if(bccomp($num,0)>=0 && bccomp($tp,2147483648)>0)  
        $tp=bcadd($tp,-4294967296);  
    if(bccomp($num,0)<0 && bccomp($tp,2147483648)<0)  
        $tp=bcadd($tp,4294967296);  
 
    return $tp;  
}

?> 