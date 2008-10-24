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
var styleList = new Array();
//名称，皮肤地址，默认宽，默认高
styleList.push(["","",0,0]);
styleList.push(["单播放按钮","mini/btplay.zip",20,15]);
styleList.push(["播放按钮+进度条黑色","mini/btplay.zip",200,15]);
styleList.push(["WMP Alone","skins/wmp_alone.zip",600,400]);



function showStyleList() {
	var ss = document.getElementById("styleSelect");
	ss.onchange = function() {
		showStyle(ss.value);
	}
	for (var i = 0; i < styleList.length; i ++) {
		ss.options.add(new Option(styleList[i][0],i));
	}
}
function showStyle(i) {
	var miniset = "&context_menu=0&show_tip=0";
	var musicurl = document.getElementById("musicurl").value;
	musicurl = escape(musicurl);
	var html = "";
	var cmpurl = "";
	if (i > 0) {
		cmpurl = "<%=getCmpPath()%>?src="+musicurl+"&skin_src="+styleList[i][1]+"&bgcolor=ffffff&play_mode=0&auto_play=1"+miniset;
		html = getcmp("cmp", styleList[i][2], styleList[i][3], cmpurl, "");
	}
	document.getElementById("preview").innerHTML = html;
	document.getElementById("htmlcode").value = html;
	document.getElementById("flashcode").value = cmpurl;
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
            <input name="" type="text" size="100" id="musicurl" value="http://" onfocus="this.select();" />
          </div>
        </div>
        <div class="mbox"><strong>选择你想要的样式：</strong>
          <div>
            <select name="" id="styleSelect">
            </select>
          </div>
        </div>
        <div class="mbox"><strong>播放器设置：</strong>
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td align="right">自动播放：</td>
              <td><input name="" type="checkbox" value="" /></td>
            </tr>
            <tr>
              <td align="right">循环播放：</td>
              <td><input name="" type="checkbox" value="" /></td>
            </tr>
            <tr>
              <td align="right">背景颜色：</td>
              <td><input type="text" size="7" maxlength="7" />
                默认为#181818</td>
            </tr>
            <tr>
              <td align="right">宽度高度：</td>
              <td><input type="text" size="4" />
                x
                <input type="text" size="4" /></td>
            </tr>
          </table>
        </div>
        <div class="mbox"><strong>调用代码：</strong>
          <div>播放器地址：
            <textarea name="" cols="100" rows="3" id="flashcode" style="width:99%;" onfocus="this.select();" wrap="virtual"></textarea>
          </div>
          <div>html代码：
            <textarea name="" cols="100" rows="10" id="htmlcode" style="width:99%;" onfocus="this.select();" wrap="virtual"></textarea>
          </div>
        </div>
        <div class="mbox"><strong>效果预览：</strong>
          <div id="preview"></div>
        </div>
      </div></td>
  </tr>
</table>
<script type="text/javascript">showStyleList();</script>
<%
end sub
%>
