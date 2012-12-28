function $(id) {
	return document.getElementById(id);
}
function rd(n) {
	var s = Math.random().toString().substr(2);
	if (n) {
		s = s.substr(0, n);	
	}
	return s;
}
function collapse(ctrlobj, showobj) {
	if(!$(showobj)) {
		return;
	}
	if($(showobj).style.display == '') {
		ctrlobj.className = 'spread';
		$(showobj).style.display = 'none';
	} else {
		ctrlobj.className = 'shrink';
		$(showobj).style.display = '';
	}
}

function getMenu() {
	var menu =
	[
		['手册首页','index.htm'],
		['基础文档','base.htm'],
		[
			['全局配置【config.xml】','config.htm'],
			['媒体列表【list.xml】','list.htm'],
			['皮肤配置【skin.xml】','skin.htm']
		],
		['API接口','api.htm'],
		[
			['ActionScript3接口','api_as3.htm'],
			['JavaScript接口','api_js.htm']
		],
		['使用范例','example.htm'],
		['常用工具','tools.htm']
	];
	var f = location.href.split("?")[0];
	f = f.substr(f.lastIndexOf('/') + 1);
	f = f.split("#")[0];
	
	var htm = '<div class="side">';
	for(var i in menu) {
		var m = menu[i];
		var s = "";
		if(typeof(m[0]) == 'object') {
			s = "sub ";	
		} else {
			m = [m];	
		}
		for(var k in m) {
			var o = '';
			var c = m[k];
			if(f == c[1]) {
				o = 'now ';
			}
			htm += '<a class="' + s + o + 'menu" href="' + c[1] + '">' + c[0] + '</a>';
		}
	}
	htm += '</div>';
	return htm;
}

document.write('<div class="header clearfix">');
document.write('<div class="flt"><a class="logo" href="index.htm" title="CMP4使用手册"></a></div>');

document.write('<div class="flt">更新日期：<a href="http://cenfunmusicplayer.googlecode.com/svn/trunk/doc/" title="查看版本库最新版">2012.07.28</a></div>');
document.write('<div class="frt">页内搜索请按【ctrl + F】</div>');

document.write('</div>');
document.write('<div class="wrap" id="wrap">');

document.write(getMenu());

document.write('<div class="mainbox">');