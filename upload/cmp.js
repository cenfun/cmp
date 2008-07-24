// CMP v3.0 show
function showcmp(id, width, height, url, vars, transparent){
	//Window | Opaque | Transparent
	var wmode = "Window";
	if (transparent) {
		wmode = "Transparent";
	}
	var html = '';
	html += '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0" width="'+width+'" height="'+height+'" id="'+id+'">';
	html += '<param name="movie" value="'+url+'" />';
	html += '<param name="quality" value="high" />';
	html += '<param name="allowFullScreen" value="true" />';
	html += '<param name="allowScriptAccess" value="always" />';
	html += '<param name="wmode" value="'+wmode+'"/>';
	html += '<param name="flashvars" value="'+vars+'" />';
	html += '<embed src="'+url+'" width="'+width+'" height="'+height+'" quality="high" pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" name="'+id+'" allowfullscreen="true" allowscriptaccess="always" wmode="'+wmode+'" flashvars="'+vars+'"></embed>';
	html += '</object>';
	document.write(html);
}