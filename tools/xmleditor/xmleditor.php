<?php
$editor_password = "cenfuncmp";

$files = array("config.xml", "list.xml");
$file_id = $_GET[id];
if (empty($file_id) || !is_numeric($file_id) || $file_id >= sizeof($files)) {
	$file_id = 0;	
}
$cmd = $_POST[cmd];
if (!empty($cmd)) {
	if ($cmd == "login") {
		$submit_password = $_POST[submit_password];
		if ($submit_password == $editor_password) {
			setcookie("password", $editor_password, time()+3600);
			header("Refresh: 0; URL=\"$PHP_SELF\""); 
		} else {
			echo '<div class="error_msg">密码错误！</div>';	
		}
	} elseif ($cmd == "logout") {
		setcookie("password", $editor_password, time()-3600);
		header("Refresh: 0; URL=\"$PHP_SELF\"");
	} elseif ($cmd == "savefile") {
		$file_content = $_POST[file_content];
		if (!empty($file_content)) {
			if (file_write($files[$file_id], $file_content)) {
				echo '<script type="text/javascript">alert("成功保存文件！");</script>';
			} else {
				echo '<div class="error_msg">写入文件失败！</div>';
			}
		} else {
			echo '<div class="error_msg">文件内容不能为空！</div>';
		}
	}
}

function file_write($filename,$contents) { 
	if ($fp=fopen($filename,"w")) {
		fwrite($fp,stripslashes($contents));
		fclose($fp);
		return true;
	} else {
		return false; 
	}
}

function file_read($filename) {
	if ($fp=fopen($filename,"r")) {
		$contents=fread($fp,filesize($filename));
		fclose($fp);
		return $contents;
	} else {
		return ""; 
	}
}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>XML Editor</title>
<style type="text/css">
body { margin:0; padding:0; font-family:Arial, Helvetica, sans-serif; font-size:12px; }
input { vertical-align:middle; }
.error_msg { text-align:center; margin:10px 10px; color:#F00; }
.login { text-align:center; margin:10px 10px; }
.logout { position:absolute; right:0px; top:0px; margin:10px 10px; }
.file_list { text-align:left; margin:10px 10px; }
.file_list label { margin:0px 10px; height:24px; line-height:24px; cursor:pointer; font-weight:bold; font-size:14px; }
.file_edit { text-align:center; margin:10px 10px; }
.file_edit input { margin:10px 10px; }
.file_content { width:98%; height:500px; font-size:12px; line-height:18px; }
</style>
</head>
<body>
<?
if ($_COOKIE['password'] != $editor_password) {
?>
<div class="login">
  <form action="<? echo $PHP_SELF ?>" method="post">
    <input type="password" name="submit_password" />
    <input type="submit" value="登录" />
    <input type="hidden" name="cmd" value="login" />
  </form>
</div>
<?
} else {
?>
<div class="logout">
  <form action="<? echo $PHP_SELF ?>" method="post">
    <input type="submit" name="" value="退出" />
    <input type="hidden" name="cmd" value="logout" />
  </form>
</div>
<div class="file_list">
  <form action="<? echo $PHP_SELF ?>" method="get">
    <?
	$num = sizeof($files);
	for($i = 0; $i < $num; $i ++) {
		if ($i == $file_id) {
			$checked = 'checked="checked"';	
		} else {
			$checked = '';
		}
    ?>
    <label for="file<? echo $i ?>">
      <input type="radio" <? echo $checked ?> id="file<? echo $i ?>" onclick="this.form.submit();" name="id" value="<? echo $i ?>" />
      <? echo $files[$i] ?></label>
    <?
	}
    ?>
  </form>
</div>
<div class="file_edit">
  <form action="<? echo $PHP_SELF ?>" method="post" onsubmit="return check(this);">
    <?
    $file_content = file_read($files[$file_id]);
	?>
    <textarea name="file_content" class="file_content"><? echo $file_content ?></textarea>
    <input type="submit" value="保存" />
    <input type="button" onclick="check(this.form);" value="检测" />
    <input type="hidden" name="cmd" value="savefile" />
  </form>
</div>
<script type="text/javascript">
function check(o){
	var str = o.file_content.value;
	//replace & to &amp;
	str = str.replace(/&(?!amp;)/ig, '&amp;'); 
	//o.file_content.value = str;
	//check xml
	var chk = checkXML(str);
	var isok = chk[0];
	var xmlDoc = chk[1];
	return isok;
}
//检测xmlDom正确性
function checkXML(str) {
	var isok = true;
	var msie = /msie/.test(navigator.userAgent.toLowerCase());
	var xmlDoc;
	var errMsg = "XML格式错误：\n\n";
	try {
		if (msie) {
			//delete utf-8 BOM
			var bom = str.charCodeAt(0)
			if (bom == "65279") {
				str = str.substr(1);
			}
			xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
			xmlDoc.async = false;
			xmlDoc.loadXML(str);
			if (xmlDoc.parseError != 0) {
				errMsg += xmlDoc.parseError.reason + "\n";
				errMsg += "行:" +xmlDoc.parseError.line + " 位置:" +xmlDoc.parseError.linepos + "\n";
				errMsg += xmlDoc.parseError.srcText + "\n";
				isok = false;
				alert(errMsg);
			}
		} else {
			var parser = new DOMParser();
			xmlDoc = parser.parseFromString(str, "text/xml");
			//是否有错误文档
			var errNode = xmlDoc.getElementsByTagName("parsererror");
			if (errNode.length) {
				var serializer = new XMLSerializer();
				var children = errNode[0].childNodes;
				for (var i = 0; i < children.length; i ++) {
					var node = children[i];
					if (node.nodeType == 1) {
						errMsg += serializer.serializeToString(node.firstChild) + "\n";
					} else {
						errMsg += serializer.serializeToString(node) + "\n";
					}
				}
				isok = false;
				alert(errMsg);
			}
		}
	} catch (e) {
		alert(e);
	}
	return [isok, xmlDoc];
}
</script>
<?
}
?>
</body>
</html>
