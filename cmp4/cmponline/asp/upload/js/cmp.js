/*
 * CMP embed JavaScript
 * http://bbs.cenfun.com/
 *
 * 1, CMP.write(id, width, height, swf_url, flashvars, params, attrs);
 * 2, var htm = CMP.create(id, width, height, swf_url, flashvars, params, attrs);
 * 3, var cmpo = CMP.get(id);
 * 4, CMP.remove(id/cmpo);
 *
 * mini version: http://cenfunmusicplayer.googlecode.com/svn/trunk/js/cmp.js
 * source file: http://cenfunmusicplayer.googlecode.com/svn/trunk/js/cmp_src.js
 * minification by: http://marijnhaverbeke.nl/uglifyjs
 */
(function(a){typeof a.CMP=="undefined"&&(a.CMP=function(){var b=/msie/.test(navigator.userAgent.toLowerCase()),c=function(a,b){if(b&&typeof b=="object")for(var c in b)a[c]=b[c];return a},d=function(a,d,e,f,g,h,i){i=c({width:d,height:e,id:a},i),h=c({allowfullscreen:"true",allowscriptaccess:"always"},h);var j,k,l,m=[];if(g){if(typeof g=="object"){for(l in g)m.push(l+"="+encodeURIComponent(g[l]));j=m.join("&")}else j=String(g);h.flashvars=j}k="<object ",k+=b?'classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=10,0,0,0" ':'type="application/x-shockwave-flash" pluginspage="http://www.adobe.com/go/getflashplayer" data="'+f+'" ';for(l in i)k+=l+'="'+i[l]+'" ';k+=b?'><param name="movie" value="'+f+'" />':">";for(l in h)k+='<param name="'+l+'" value="'+h[l]+'" />';k+="</object>";return k},e=function(c){var d=document.getElementById(String(c));if(!d||d.nodeName.toLowerCase()!="object")d=b?a[c]:document[c];return d},f=function(a){if(a){for(var b in a)typeof a[b]=="function"&&(a[b]=null);a.parentNode.removeChild(a)}},g=function(a){if(a){var c=typeof a=="string"?e(a):a;if(c&&c.nodeName=="OBJECT"){b?(c.style.display="none",function(){c.readyState==4?f(c):setTimeout(arguments.callee,15)}()):c.parentNode.removeChild(c);return!0}}return!1};return{create:function(){return d.apply(this,arguments)},write:function(){var a=d.apply(this,arguments);document.write(a);return a},get:function(a){return e(a)},remove:function(a){return g(a)}}}())})(window)