function ajaxSend(method,url,async,data,completeHd,errorHd) {
	var xmlHttp = window.ActiveXObject ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();
	if(xmlHttp){
		xmlHttp.onreadystatechange = function() {
			if(xmlHttp.readyState==4){
				if(xmlHttp.status==200){
					var data = xmlHttp.responseText;
					completeHd(data);
					xmlHttp = null;
				}else{
					errorHd("Request Error: " + xmlHttp.status);
				}
			} 
		}
		if(method.toUpperCase()!="POST"){
			method = "GET";	
		}
		xmlHttp.open(method,url,async);
		xmlHttp.send(data);
	}
}
function highlight(o,c1,c2){
	o.style.background=c1;
	o.onmouseout=function(){
		o.style.background=c2;
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
//open a new window
function winopen(url,name,width,height,str){
	var winopen = window.open(url,name,'width='+width+',height='+height+','+str+',menubar=0,status=0');
	//str:  resizable=0,scrollbars=yes,menubar=no,status=0
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