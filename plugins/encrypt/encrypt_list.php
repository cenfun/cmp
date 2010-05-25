<?php
error_reporting(0);

//加密密钥，如果需要改动，请一定保持与插件程序里的解密密匙一样，并重新编译一下flash插件
$key = "756e35bd9441e66e001ca73024b9b426";
//多个列表可以加在数字里，如array("list1.xml", "list2.xml")
$lists = array("list.xml");
//读取每个列表并加密
$data = "";
foreach ($lists as $list) {
	$data .= getList($list);	
}
if (!empty($data)) {
	$str = xxtea_encrypt($data, $key);
	$str = base64_encode($str);
	echo $str;
}

//读取列表的子节点，注意必须是标准的CMP4列表文件格式
function getList($url) {
	$xml = "";
	if (file_exists($url)) {
		$reader = new XMLReader();
		$reader->open($url);
		while ($reader->read()) {
			if ($reader->nodeType == XMLREADER::ELEMENT) {
				$xml = $reader->readInnerXML();
				$reader->next();
			}
		}
	}
	return $xml;
}
//============================================================================
function long2str($v, $w) {
	$len = count($v);
	$n = ($len - 1) << 2;
	if ($w) {
		$m = $v[$len - 1];
		if (($m < $n - 3) || ($m > $n)) return false;
		$n = $m;
	}
	$s = array();
	for ($i = 0; $i < $len; $i++) {
		$s[$i] = pack("V", $v[$i]);
	}
	if ($w) {
		return substr(join('', $s), 0, $n);
	}
	else {
		return join('', $s);
	}
}

function str2long($s, $w) {
	$v = unpack("V*", $s. str_repeat("\0", (4 - strlen($s) % 4) & 3));
	$v = array_values($v);
	if ($w) {
		$v[count($v)] = strlen($s);
	}
	return $v;
}

function int32($n) {
	while ($n >= 2147483648) $n -= 4294967296;
	while ($n <= -2147483649) $n += 4294967296;
	return (int)$n;
}

function xxtea_encrypt($str, $key) {
	if ($str == "") {
		return "";
	}
	$v = str2long($str, true);
	$k = str2long($key, false);
	if (count($k) < 4) {
		for ($i = count($k); $i < 4; $i++) {
			$k[$i] = 0;
		}
	}
	$n = count($v) - 1;

	$z = $v[$n];
	$y = $v[0];
	$delta = 0x9E3779B9;
	$q = floor(6 + 52 / ($n + 1));
	$sum = 0;
	while (0 < $q--) {
		$sum = int32($sum + $delta);
		$e = $sum >> 2 & 3;
		for ($p = 0; $p < $n; $p++) {
			$y = $v[$p + 1];
			$mx = int32((($z >> 5 & 0x07ffffff) ^ $y << 2) + (($y >> 3 & 0x1fffffff) ^ $z << 4)) ^ int32(($sum ^ $y) + ($k[$p & 3 ^ $e] ^ $z));
			$z = $v[$p] = int32($v[$p] + $mx);
		}
		$y = $v[0];
		$mx = int32((($z >> 5 & 0x07ffffff) ^ $y << 2) + (($y >> 3 & 0x1fffffff) ^ $z << 4)) ^ int32(($sum ^ $y) + ($k[$p & 3 ^ $e] ^ $z));
		$z = $v[$n] = int32($v[$n] + $mx);
	}
	return long2str($v, false);
}
?>