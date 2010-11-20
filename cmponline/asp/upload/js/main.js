var loading = $('<img src="images/loading.gif" width="16" height="16" align="absmiddle" alt="Loading ..." />');

function getcmp(id, w, h, url, params) {
	var _params = { allowfullscreen : "true", allowscriptaccess : "always"};
	if (params && typeof params === "object") {
		for (var k in params) {
			_params[k] = params[k];	
		}
	}
	var htm = '<object type="application/x-shockwave-flash" data="'+url+'" width="'+w+'" height="'+h+'" id="'+id+'">\n';
	htm += '<param name="movie" value="'+url+'" />\n';
	for (var p in _params) {
		htm += '<param name="'+p+'" value="'+_params[p]+'" />\n';
	}
	htm += '</object>';
	return htm;
}

function show_vars(type, cls) {
	
	if ($(cls).html()) {
		$(cls).slideToggle(function(){
			$(this).css("overflow", "auto");	
		});
	} else {
		var str;
		if ((type == "config" && typeof CMP_CONFIG !== "undefined") || (type == "list" && typeof CMP_LIST !== "undefined")) {
			str = '<table width="100%" border="0" cellspacing="0" cellpadding="0">';
			var obj = type == "config" ? CMP_CONFIG : CMP_LIST;
			for (var k in obj) {
				str += '<tr onmouseover="highlight(this,\'#F9F9F9\');">';
				str += '<td nowrap="nowrap" align="right">'+k+'</td>';
				str += '<td>'+obj[k]+'</td>';
				str += '</tr>';
			}
			str += '</table>';
		} else {
			str = "错误";	
		}
		$(cls).hide().html(str).slideDown(function(){
			$(this).css("overflow", "auto");	
		});
	
	}
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
//检查非法字符
//str 要检查的字符
//badwords 非法字符 &|<>=
function checkbadwords(str, badwords) {
	if (typeof (str) != "string" || typeof (badwords) != "string") {
		return (false);
	}
	for (i=0; i<badwords.length; i++) {
		bad = badwords.charAt(i);
		for (j=0; j<str.length; j++) {
			if (bad == str.charAt(j)) {
				return false;
				break;
			}
		}
	}
	return true;
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
//open a new window
function winopen(url,name,width,height,str){
	var winopen = window.open(url,name,'width='+width+',height='+height+','+str+',menubar=0,status=0');
	//str:  resizable=0,scrollbars=yes,menubar=no,status=0
}
