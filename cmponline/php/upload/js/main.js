// CMP v3.0 show
function showcmp(id, width, height, url, vars, transparent) {
	var html = getcmp(id, width, height, url, vars, transparent);
	document.write(html);
}
function getcmp(id, width, height, url, vars, transparent) {
	//Window | Opaque | Transparent
	var wmode = "";
	if (transparent == true) {
		wmode = "Transparent";
	} else if (transparent == false) {
		wmode = "Opaque";	
	}
	var html = '';
	html += '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,124,0" ';
	html += 'width="'+width+'" ';
	html += 'height="'+height+'" ';
	html += 'id="'+id+'"';
	html += '>\n';
	html += '<param name="movie" value="'+url+'" />\n';
	html += '<param name="quality" value="high" />\n';
	html += '<param name="allowFullScreen" value="true" />\n';
	html += '<param name="allowScriptAccess" value="always" />\n';
	if (wmode) {html += '<param name="wmode" value="'+wmode+'"/>\n';}
	if (vars) {html += '<param name="flashvars" value="'+vars+'" />\n';}
	//
	html += '<embed pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" ';
	html += 'width="'+width+'" ';
	html += 'height="'+height+'" ';
	html += 'name="'+id+'" ';
	html += 'src="'+url+'" ';
	html += 'quality="high"  ';
	html += 'allowfullscreen="true" ';
	html += 'allowscriptaccess="always" ';
	if (wmode) {html += 'wmode="'+wmode+'" ';}
	if (vars) {html += 'flashvars="'+vars+'" '}
	html += '></embed>\n';
	html += '</object>';
	return html;
}

function highlight(o,c){
	o.style.backgroundColor=c;
	o.onmouseout=function(){
		o.style.backgroundColor="";
	}
}
function CheckAll(o,form){
	for (var i=0;i<form.elements.length;i++){
		var e = form.elements[i];
		if (e.type=="checkbox" && e.name.indexOf("idlist")!=-1 && e.disabled==false){
			e.checked = o.checked;
		}
	}
}

//检测xmlDom正确性
function checkXML(str) {
	var isok = true;
	var msie = /msie/.test(navigator.userAgent.toLowerCase());
	var xmlDoc;
	var errMsg = "XML格式错误：\n\n";
	try {
		if (msie) {
			xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
			xmlDoc.async= false;
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

//coolie//////////////////////////////////////////
function saveCookie(name, value, expires, path, domain, secure) {
	var strCookie = name+"="+value;
	if (expires) {
		var curTime = new Date();
		curTime.setTime(curTime.getTime()+expires*24*60*60*1000);
		strCookie += "; expires="+curTime.toGMTString();
	}
	strCookie += (path) ? "; path="+path : "";
	strCookie += (domain) ? "; domain="+domain : "";
	strCookie += (secure) ? "; secure" : "";
	document.cookie = strCookie;
}
function getCookie(name) {
	var strCookies = document.cookie;
	var cookieName = name+"=";
	valueBegin = strCookies.indexOf(cookieName);
	if (valueBegin == -1) {
		return null;
	}
	valueEnd = strCookies.indexOf(";", valueBegin);
	if (valueEnd == -1) {
		valueEnd = strCookies.length;
	}
	value = strCookies.substring(valueBegin+cookieName.length, valueEnd);
	return value;
}
function checkCookieExist(name) {
	if (getCookie(name)) {
		return true;
	} else {
		return false;
	}
}
function deleteCookie(name, path, domain) {
	var strCookie;
	if (checkCookieExist(name)) {
		strCookie = name+"=";
		strCookie += (path) ? "; path="+path : "";
		strCookie += (domain) ? "; domain="+domain : "";
		strCookie += "; expires=Thu, 01-Jan-70 00:00:01 GMT";
		document.cookie = strCookie;
	}
}
