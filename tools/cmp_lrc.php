<? 

$title = $_REQUEST[title]; 

$arr = split("-", $title);
$size = sizeof($arr);

if ($size > 1) {
	$title = trim($arr[0]);
	$artist = trim($arr[1]);
} else {
	$artist = $_REQUEST[artist];
}



$serverList = array("1"=>"http://ttlrcct.qianqian.com/dll/lyricsvr.dll", "2"=>"http://ttlrccnc.qianqian.com/dll/lyricsvr.dll");

$sid = $_REQUEST[sid];
if (empty($sid)) $sid = 1;

$server = $serverList[$sid];

$doc = new DOMDocument();
$doc->load($server."?sh?Artist=".qianqian_code($artist)."&Title=".qianqian_code($title)."&Flags=0");
   
$lrcNode = $doc->getElementsByTagName("lrc");
foreach($lrcNode as $lrc) {  
   $id=$lrc->getAttribute("id");
   $artist=iconv('UTF-8','GBK',$lrc->getAttribute("artist"));  
   $title=iconv('UTF-8','GBK',$lrc->getAttribute("title"));  
   $code=CodeFunc($id,$artist,$title);  
   $lrcstr=iconv('UTF-8','GBK',file_get_contents($server."?dl?Id=".$id."&Code=".$code));  
   echo $lrcstr;
   break;
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
function CodeFunc($Id,$artist,$title){  
    $Id=(int)$Id;  
    $utf8Str=SetToHexString(iconv('GBK','UTF-8',$artist.$title));  
 
    $length=strlen($utf8Str)/2;  
    for($i=0;$i<=$length-1;$i++)  
        eval('$song['.$i.'] = 0x'.substr($utf8Str,$i*2,2).';');  
 
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

?> 