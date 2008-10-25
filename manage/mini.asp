<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
site_title = "迷你播放器"
header()
menu()
main()
footer()

sub main()
%>
<script type="text/javascript">
//当前样式ID
var styleId;
//Mini皮肤列表=================================================================
var styleList = new Array();
styleList.push(["","","","",""]);

//名称，皮肤地址，默认宽，默认高，补充说明
styleList.push(["单播放按钮","mini/mini01.zip",25,20,""]);
styleList.push(["海蓝一","mini/mini02.zip",73,24,"宽度自适应，可设置为100%"]);
styleList.push(["海蓝二","mini/mini02.zip",200,24,"宽度自适应，可设置为100%"]);
styleList.push(["Dewplayer Mini","mini/mini03.zip",16,16,"仅播放按钮"]);
styleList.push(["Dewplayer Basic","mini/mini03.zip",153,16,"播放按钮和进度条"]);
styleList.push(["Dewplayer Classic","mini/mini03.zip",172,16,"播放，停止，进度条"]);
styleList.push(["Dewplayer Multi","mini/mini03.zip",201,16,"播放，停止，静音，进度条"]);

//如有更多Mini皮肤样式，请安装以上格式在此添加即可

//============================================================================
function $(s) {return document.getElementById(s);}
function showStyleList() {
	var ss = $("styleSelect");
	ss.onchange = function() {
		styleId = ss.value;
		getStyle();
	}
	for (var i = 0; i < styleList.length; i ++) {
		ss.options.add(new Option(styleList[i][0],i));
	}
}
function getStyle() {
	//取得原有样式宽高设置
	$("cmp_width").value = styleList[styleId][2];
	$("cmp_height").value = styleList[styleId][3];
	showStyle();
	//详细说明
	$("readme").innerHTML = styleList[styleId][4];
}
function showStyle() {
	//迷你设置
	var miniset = "&context_menu=0&show_tip=0";
	//取得音乐地址
	var musicurl = $("musicurl").value;
	if (musicurl) {
		musicurl = escape(musicurl);
	}
	//取得设置
	var auto_play = $("cmp_auto_play").checked;
	var play_mode = $("cmp_play_mode").checked;
	var bgcolor = $("cmp_bgcolor").value;
	var cmp_width = $("cmp_width").value;
	var cmp_height = $("cmp_height").value;
	var cmp_type = $("cmp_type").value;
	//生成代码
	var html = "";
	var cmpurl = "";
	if (styleId > 0) {
		//生成cmp的调用地址
		cmpurl = "<%=getCmpPath()%>?src="+musicurl+"&skin_src="+styleList[styleId][1];
		if (auto_play) {cmpurl += "&auto_play=1";}
		if (play_mode) {cmpurl += "&play_mode=1";}
		if (bgcolor) {
			if (bgcolor.charAt(0) == "#") {
				bgcolor = bgcolor.substring(1);
			}
			cmpurl += "&bgcolor="+bgcolor;
		}
		if (cmp_type) {cmpurl += "&type="+cmp_type;}
		cmpurl += miniset;
		//生成html地址
		html = getcmp("cmp", cmp_width, cmp_height, cmpurl, "", true);
	}
	$("htmlcode").value = html;
	$("flashcode").value = cmpurl;
	showPreview();
}
function showPreview() {
	$("preview").innerHTML = $("htmlcode").value;
}
</script>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">迷你播放器</th>
  </tr>
  <tr>
    <td><div>
        <div class="mbox">当你在发表信息时，如果想要快捷的插入某个音乐或视频，这里免费提供各种Mini播放器供您使用，无需注册，仅仅填写你要播放的音乐或视频地址即可。</div>
        <div class="mbox"><strong>音乐或视频地址：</strong><span>(mp3,flv)</span>
          <div>
            <input type="text" size="100" id="musicurl" value="http://localhost/music/128kbps_44kHz.mp3" onfocus="this.select();" onchange="showStyle();" />
          </div>
        </div>
        <div class="mbox"><strong>选择你想要的样式：</strong>
          <div>
            <select id="styleSelect">
            </select>
            <span id="readme"></span></div>
        </div>
        <div class="mbox"><strong>播放器设置：</strong>
          <table border="0" cellspacing="5" cellpadding="3">
            <tr>
              <td>自动播放
                <input type="checkbox" value="1" id="cmp_auto_play" /></td>
              <td>循环播放
                <input type="checkbox" value="1" id="cmp_play_mode" /></td>
              <td>背景颜色
                <input type="text" size="7" maxlength="7" id="cmp_bgcolor" /></td>
              <td>宽度
                <input type="text" size="4" id="cmp_width" />
              </td>
              <td> 高度
                <input type="text" size="4" id="cmp_height" /></td>
              <td>类型
                <select id="cmp_type">
                  <option value="">自动识别</option>
                  <option value="1">mp3音频</option>
                  <option value="2">flv视频</option>
                  <option value="3">wmp类型</option>
                </select></td>
              <td><input type="button" value="更新设置" onclick="showStyle();" /></td>
            </tr>
          </table>
        </div>
        <div class="mbox"><strong>调用代码：</strong>
          <div>播放器调用地址：
            <textarea name="" cols="100" rows="2" id="flashcode" style="width:99%;" onfocus="this.select();" wrap="virtual"></textarea>
          </div>
          <div>html代码：
            <textarea name="" cols="100" rows="10" id="htmlcode" style="width:99%;" onfocus="this.select();" wrap="virtual"></textarea>
          </div>
        </div>
        <div class="mbox"><strong>效果预览：</strong>
          <input type="button" value="刷新预览" onclick="showPreview();" />
          <div id="preview" style="margin:10px auto;"></div>
        </div>
      </div></td>
  </tr>
</table>
<script type="text/javascript">showStyleList();</script>
<%
end sub
%>
