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

$surl = "http://ttlrcct.qianqian.com/dll/lyricsvr.dll?svrlst";
$sdata = file_get_contents($surl);
$doc = new DOMDocument();
$doc->loadXML($sdata);
$slist = $doc->getElementsByTagName("server");
$serverList = array();
foreach($slist as $url) { 
	array_push($serverList, $url->getAttribute("url"));
}
$sid = $_REQUEST[sid];
if (empty($sid)) {
	$sid = 1;
}
$server = $serverList[$sid];
$lurl = $server."?sh?Artist=".qianqian_code($artist)."&Title=".qianqian_code($title)."&Flags=0";
$ldata = file_get_contents($lurl);

$doc = new DOMDocument();
$doc->loadXML($ldata);


$lrcNode = $doc->getElementsByTagName("lrc");
foreach($lrcNode as $lrc) {  
	$id = $lrc->getAttribute("id");
	$artist = $lrc->getAttribute("artist");
	$title = $lrc->getAttribute("title");
	$utf8Str = SetToHexString($artist.$title);  
	$code = getCode($id, $utf8Str);
	$url = $server."?dl?Id=".$id."&Code=".$code;
	$data = file_get_contents($url);
	$data = iconv('UTF-8','GBK', $data);
	if (trim($data)) {
		echo $data;
		break;
	}
}

function getCode($Id, $utf8Str){  
    $Id = (int) $Id;
    $length = strlen($utf8Str) / 2;  
    for($i=0;$i<$length;$i++)  {
        eval('$song['.$i.'] = 0x'.substr($utf8Str,$i*2,2).';');  
	}
    $tmp2=0;  
    $tmp3=0;  

	//右移8位后为0x0000015F  
    $tmp1 = ($Id & 0x0000FF00) >> 8; 
	//tmp1 0x0000005F  
    if ( ($Id & 0x00FF0000) == 0 ) {  
        $tmp3 = 0x000000FF & ~$tmp1; //CL 0x000000E7  
    } else {  
        $tmp3 = 0x000000FF & (($Id & 0x00FF0000) >> 16); //右移16位后为0x00000001  
    }  
    $tmp3 = $tmp3 | ((0x000000FF & $Id) << 8); //tmp3 0x00001801  
    $tmp3 = $tmp3 << 8; //tmp3 0x00180100  
    $tmp3 = $tmp3 | (0x000000FF & $tmp1); //tmp3 0x0018015F  
    $tmp3 = $tmp3 << 8; //tmp3 0x18015F00  
    if ( ($Id & 0xFF000000) == 0 ) {  
        $tmp3 = $tmp3 | (0x000000FF & (~$Id)); //tmp3 0x18015FE7  
    } else {  
        $tmp3 = $tmp3 | (0x000000FF & ($Id >> 24)); //右移24位后为0x00000000  
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
function qianqian_code($str){  
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