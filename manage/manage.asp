<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
'检测用户是否登录
If Session(CookieName & "_username")="" Then
	response.Redirect("index.asp")
else
	header()
	menu()
	Select Case Request.QueryString("action")
		Case "userinfo"
			userinfo()
		Case "saveinfo"
			saveinfo()	
		Case "config"
			config()
		Case "saveconfig"
			saveconfig()
		Case "list"
			list()
		Case "savelist"
			savelist()
		Case Else
			main()
	End Select
	footer()
end if

sub list()
dim strContent,id
sql = "select id,list from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
	id = rs("id")
	if trim(rs("list"))<>"" then
		strContent = rs("list")
	else
		strContent = "<list>" & Chr(13) & Chr(10) & "</list>"
	end if
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=savelist" onsubmit="return check_list(this);">
    <input name="id" type="hidden" value="<%=id%>" />
    <tr>
      <th align="left">CMP列表文件编辑:</th>
    </tr>
    <tr>
      <td align="center"><textarea name="list" rows="30" id="list" style="width:99%;"><%=strContent%></textarea></td>
    </tr>
    <tr>
      <td align="center"><input name="list_submit" type="submit" id="list_submit" style="width:50px;" value="提交" /></td>
    </tr>
    <tr>
      <td><div style="padding:5px 5px; margin-top:5px; border-top:1px dashed #CCCCCC;"><strong>l</strong> 标记专辑信息，属性有<br />
          <strong>title</strong>: 专辑名称 <br />
          <strong>m</strong> 标记单个音乐信息，属性有<br />
          <strong>type</strong>: 音乐类型，不填将根据文件后缀(扩展名)自动识别，支持三种：1,MP3音频  2,FLV/MP4视频  3,WMP类型<br />
          <strong>src</strong>: 音乐地址，必填<br />
          <strong>lrc</strong>: 歌词或字幕地址 <br />
          <strong>time</strong>: 视频总时间，仅针对部分非标准视频，一般不用<br />
          <strong>&lt;m&gt;</strong>音乐名称<strong>&lt;/m&gt;</strong> <br />
          一个完整的例子如下：<br />
          &lt;list&gt;<br />
          &lt;l title=&quot;最新&quot;&gt;<br />
          &lt;m type=&quot;&quot; src=&quot;test.mp3&quot; lrc=&quot;&quot;&gt;mp3音频&lt;/m&gt;<br />
          &lt;m type=&quot;&quot; src=&quot;test.mp4&quot; lrc=&quot;&quot; time=&quot;&quot;&gt;flv视频/高清h264视频/AAC音频&lt;/m&gt;<br />
          &lt;m type=&quot;&quot; src=&quot;test.wma&quot; lrc=&quot;&quot;&gt;wma音频/wmv/wav/mid&lt;/m&gt;<br />
          &lt;/l&gt;<br />
          &lt;l title=&quot;欧美&quot;&gt;<br />
          &lt;/l&gt;<br />
          &lt;l title=&quot;日韩&quot;&gt;&lt;/l&gt;<br />
          &lt;/list&gt;<br />
        </div></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_list(o){
	return true;
}
</script>
<%
end sub

sub savelist()
	dim list,id
	list = request.Form("list")
	id = Checkstr(request.Form("id"))
	conn.execute("update cmp_user set list='"&list&"' where username='" & Session(CookieName & "_username") & "'")
	SucMsg="修改成功！"
	Cenfun_suc("manage.asp?action=list")
	'重建静态数据
	if xml_make="1" then
		dim objStream
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err Then 
			Err.Clear
			ErrMsg = "服务器不支持ADODB.Stream"
			cenfun_error()
		else
			With objStream
			.Open
			.Charset = "utf-8"
			.Position = objStream.Size
			.WriteText = list
			.SaveToFile Server.Mappath(xml_path & "/" & id & xml_list),2 
			.Close
			End With
		end if
		Set objStream = Nothing
	end if
end sub


sub config()
dim strContent,id
sql = "select id,cmp_name,cmp_url,config from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
	id = rs("id")
	if trim(rs("config"))<>"" then
		strContent = rs("config")
	else
		dim cr
		cr = Chr(13) & Chr(10)  & Chr(13) & Chr(10) 
		strContent = "<cmp name="""" url="""" list="""" >" & cr
		strContent = strContent & "<config language="""" volume="""" timeout="""" skin_id="""" list_id="""" play_mode="""" auto_play="""" "
		strContent = strContent & "max_video="""" mixer_color="""" mixer_filter="""" mixer_displace="""" mixer_id="""" "
		strContent = strContent & "video_smoothing="""" plugins_disabled="""" check_policyfile="""" show_tip="""" />" & cr
		strContent = strContent & "<skins>"&cr&"</skins>" & cr 
		strContent = strContent & "<plugins>"&cr&"</plugins>" & cr
		strContent = strContent & "<count src="""&site_count&""" />" & cr
		strContent = strContent & "</cmp>"
		conn.execute("update cmp_user set config='"&strContent&"' where id=" & id & " ")
	end if
	'替换列表地址
	dim re
	Set re=new RegExp
	re.IgnoreCase =True
	re.Global=True
	re.Pattern="(<cmp[^>]+list *= *\"")[^\r]*?(\""[^>]*>)"
	if xml_make="1" then
		strContent=re.Replace(strContent,"$1" & xml_path & "/" & rs("id") & xml_list & "$2")
	else
		strContent=re.Replace(strContent,"$1list.asp?id="&rs("id")&"$2")
	end if
	'名称，网址替换
	re.Pattern="(<cmp[^>]+name *= *\"")[^\r]*?(\""[^>]*>)"
	strContent=re.Replace(strContent,"$1" & rs("cmp_name") & "$2")
	re.Pattern="(<cmp[^>]+url *= *\"")[^\r]*?(\""[^>]*>)"
	strContent=re.Replace(strContent,"$1" & rs("cmp_url") & "$2")
	Set re=nothing
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveconfig" onsubmit="return check_config(this);">
    <input name="id" type="hidden" value="<%=id%>" />
    <tr>
      <th align="left">CMP配置文件编辑:</th>
    </tr>
    <tr>
      <td align="center"><textarea name="config" rows="30" id="config" style="width:99%;"><%=strContent%></textarea></td>
    </tr>
    <tr>
      <td align="center"><input name="config_submit" type="submit" id="config_submit" style="width:50px;" value="提交" /></td>
    </tr>
    <tr>
      <td><div style="padding:5px 5px; margin-top:5px; border-top:1px dashed #CCCCCC;">注：其中name,url,list属性会自动根据个人资料和站点设置进行替换<br />
      全局参数配置：(不填将在第一次打开时使用系统默认值，之后将读取存储值，必须开启Flash本地存储)<br />
language: 使用语言，支持三种：简体中文(zh-cn)；繁体中文(zh-tw)；英文(en)，括号中为其使用值<br />
volume: 初始化音量值，可用值为0-1之间，默认0.8，表示80%的音量，0表示静音，1为最大音量<br />
timeout: 自定义连接超时，单位毫秒，默认15000，即15秒<br />
skin_id: 皮肤ID，如skin_id=&quot;3&quot;表示使用皮肤列表的第3个皮肤；0为使用系统默认皮肤，默认为0；-1为随机<br />
list_id: 指定初始的列表分类ID，如list_id=&quot;2&quot;表示指定播放第2个分类，默认为1；-1为随机<br />
play_mode: 播放模式，支持三种：顺序播放(0)；重复播放(1)；随机播放(2)；默认0<br />
auto_play: 是否启用自动播放：不启用(0)；启用(1)；播放第n个(n)；默认0<br />
max_video: 打开时是否最大化视频窗口：否(0)；是(1)；默认0<br />
mixer_color: 混音器的颜色，如：#00ff00，默认为0xa4eb0c<br />
mixer_filter: 是否开启混音器滤镜：关闭(0)；开启(1)；默认0<br />
mixer_displace: 是否开启滤镜随机置换：关闭(0)；开启(1)；默认0<br />
mixer_id: 混音器ID，如目前支持10种效果，即可选1至10，默认为1；-1为随机<br />
video_smoothing: 是否启用视频缩放时进行平滑处理：不启用(0)；启用(1)；默认1<br />
plugins_disabled: 是否禁用插件：不禁用(0)；禁用(1)；默认0<br />
check_policyfile: 是否下载跨域策略文件：不下载(0)；下载(1)，仅对播放跨域mp3时显示soundmixer和id3有用，默认1<br />
show_tip: 是否延时显示按钮等文字提示信息：不显示(0)；显示(500)，数值表示延时的毫秒数，默认延时500毫秒<br />
      皮肤列表：<br />
src: 皮肤包路径<br />
mixer_id/mixer_color/show_tip: 指定单个皮肤的配置参数，为空则使用全局参数配置<br />
      &lt;skins&gt;<br />
&lt;skin src=&quot;skins/wmp11.zip&quot; mixer_id=&quot;&quot; mixer_color=&quot;&quot; show_tip=&quot;&quot; /&gt;<br />
&lt;skin src=&quot;skins/blue_full.zip&quot; mixer_id=&quot;2&quot; mixer_color=&quot;&quot; show_tip=&quot;&quot; /&gt;<br />
&lt;/skins&gt;<br />
      插件列表：<br />
name: 插件名称，非必填<br />
xywh: 为4个数值，用英文逗号(,)隔开，分别表示对象的x横坐标、y纵坐标、w宽、h高<br />
src: 插件路径，必填<br />
lock: 是否锁定对象，锁定后将不能拖动对象：1表示锁定；0表示不锁定<br />
display: 是否显示对象：1表示显示对象；0表示隐藏对象<br />
istop: 是否置顶插件：0为最底层(默认)；1为顶层<br />
多个插件的顺序即为其叠放层次，请注意不要被最大的背景遮挡，即将不用显示的插件和背景图放在最下层<br />
      &lt;plugins&gt;<br />
&lt;plugin name=&quot;大背景&quot; xywh=&quot;0, 0, 100P, 100P&quot; src=&quot;plugins/bigbg.swf&quot; lock=&quot;1&quot; display=&quot;1&quot; istop=&quot;0&quot; /&gt;<br />
&lt;/plugins&gt;</div></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_config(o){
	return true;
}
</script>
<%
end sub

sub saveconfig()
	dim config,id
	config = request.Form("config")
	id = Checkstr(request.Form("id"))
	conn.execute("update cmp_user set config='"&config&"' where username='" & Session(CookieName & "_username") & "'")
	SucMsg="修改成功！"
	Cenfun_suc("manage.asp?action=config")
	'重建静态数据
	if xml_make="1" then
		dim objStream
		Set objStream = Server.CreateObject("ADODB.Stream")
		If Err Then 
			Err.Clear
			ErrMsg = "服务器不支持ADODB.Stream"
			cenfun_error()
		else
			With objStream
			.Open
			.Charset = "utf-8"
			.Position = objStream.Size
			.WriteText = config
			.SaveToFile Server.Mappath(xml_path & "/" & id & xml_config),2 
			.Close
			End With
		end if
		Set objStream = Nothing
	end if
end sub

sub userinfo()
sql = "select * from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveinfo&do=info" onsubmit="return check_info(this);">
    <tr>
      <th colspan="2" align="left">个人资料:</th>
    </tr>
    <tr>
      <td align="right">用户名：</td>
      <td><%=rs("username")%></td>
    </tr>
    <tr>
      <td align="right">注册日期：</td>
      <td><%=rs("regtime")%></td>
    </tr>
    <tr>
      <td align="right">最后登录日期：</td>
      <td><%=rs("lasttime")%></td>
    </tr>
    <tr>
      <td align="right">最后访问IP：</td>
      <td><%=rs("lastip")%> <a href="<%=getIpUrl(rs("lastip"))%>" target="_blank">查询</a></td>
    </tr>
    <tr>
      <td align="right">登录次数：</td>
      <td><%=rs("logins")%></td>
    </tr>
    <tr>
      <td align="right">Email：</td>
      <td><input name="email" type="text" id="email" size="30" maxlength="50" value="<%=rs("email")%>" /></td>
    </tr>
    <tr>
      <td align="right">QQ：</td>
      <td><input name="qq" type="text" id="qq" size="30" maxlength="50" value="<%=rs("qq")%>" /></td>
    </tr>
    <tr>
      <td align="right">播放器名称：</td>
      <td><input name="cmp_name" type="text" id="cmp_name" size="50" maxlength="200" value="<%=rs("cmp_name")%>" /></td>
    </tr>
    <tr>
      <td align="right">网址：</td>
      <td><input name="cmp_url" type="text" id="cmp_url" size="50" maxlength="200" value="<%=rs("cmp_url")%>" /></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
    </tr>
  </form>
</table>
<%
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveinfo&do=pass" onsubmit="return check_pass(this);">
    <tr>
      <th colspan="2" align="left">修改密码:</th>
    </tr>
    <tr>
      <td align="right">原有密码：</td>
      <td><input name="oldpassword" type="password" id="oldpassword" size="20" /></td>
    </tr>
    <tr>
      <td align="right">新密码：</td>
      <td><input name="newpassword" type="password" id="newpassword" size="20" /></td>
    </tr>
    <tr>
      <td align="right">确认密码：</td>
      <td><input name="passwordcheck" type="password" id="passwordcheck" size="20" /></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_info(o){
	if(o.cmp_name.value==""){
		alert("播放器名称不能为空！");
		o.cmp_name.focus();
		return false;
	}
	return true;
}	
function check_pass(o){
	if(o.oldpassword.value==""){
		alert("原有密码不能为空！");
		o.oldpassword.focus();
		return false;
	}
	if(o.newpassword.value==""){
		alert("新密码不能为空！");
		o.newpassword.focus();
		return false;
	}
	if(o.passwordcheck.value==""){
		alert("确认密码不能为空！");
		o.passwordcheck.focus();
		return false;
	}
	if(o.newpassword.value!=o.passwordcheck.value){
		alert("确认密码和新密码不一致，请重新输入！");
		o.newpassword.focus();
		o.newpassword.value = "";
		o.passwordcheck.value = "";
		return false;
	}
	return true;
}	
</script>
<%if Session(CookieName & "_username") = Session(CookieName & "_admin") then%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveinfo&do=name" onsubmit="return check_name(this);">
    <tr>
      <th colspan="2" align="left">修改用户名:</th>
    </tr>
    <tr>
      <td align="right">密码：</td>
      <td><input name="password" type="password" id="password" size="20" />
        必须输入当前用户密码才能修改</td>
    </tr>
    <tr>
      <td align="right">用户名：</td>
      <td><input name="username" type="text" id="username" size="20" maxlength="200" value="<%=Session(CookieName & "_admin")%>" />
        仅管理员可修改</td>
    </tr>
    <tr>
      <td align="right">注：</td>
      <td>请不要使用常见的管理员名，如admin等，以防止恶意破解；<br />
        请务必牢记修改后的用户名，如果忘记请打开数据库查阅。</td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_name(o){
	if(o.password.value==""){
		alert("用户密码不能为空！");
		o.password.focus();
		return false;
	}
	if(o.username.value==""){
		alert("用户名不能为空！");
		o.username.focus();
		return false;
	}
	return true;
}	
</script>
<%end if%>
<%
end sub

sub saveinfo()
dim username
username = Session(CookieName & "_username")
if Request.QueryString("do")="info" then
	'修改用户信息
	dim email,qq,cmp_name,cmp_url
	email=Checkstr(Request.Form("email"))
	qq=Checkstr(Request.Form("qq"))
	cmp_name=Checkstr(Request.Form("cmp_name"))
	cmp_url=Checkstr(Request.Form("cmp_url"))
	sql = "update cmp_user set email='"&email&"',qq='"&qq&"',cmp_name='"&cmp_name&"',cmp_url='"&cmp_url&"' where username='"&username&"'"
	'response.Write(sql)
	conn.execute(sql)
	SucMsg="修改成功！"
	Cenfun_suc("manage.asp?action=userinfo")
elseif Request.QueryString("do")="pass" then
	'修改用户密码
	dim oldpassword,newpassword
	oldpassword=md5(request.Form("oldpassword")+username,16)
	sql = "select id from cmp_user where username='"&username&"' and password='"&oldpassword&"'"
	set rs=conn.Execute(sql)
	if not rs.eof then
		newpassword=md5(request.Form("newpassword")+username,16)
		conn.execute("update cmp_user set [password]='"&newpassword&"' where username='"&username&"'")
		SucMsg="修改成功！"
		Cenfun_suc("manage.asp?action=userinfo")
	else
		ErrMsg = "您输入的原密码错误，请返回重试"
		cenfun_error()
	end if
	rs.close
	set rs=nothing
elseif Request.QueryString("do")="name" then
	if username = Session(CookieName & "_admin") then
		'修改新用户名
		dim password,newusername,updatepassword
		newusername=Checkstr(Request.Form("username"))
		if newusername <> username then
			'验证密码
			password=md5(request.Form("password")+username,16)
			sql = "select id from cmp_user where username='"&username&"' and password='"&password&"'"
			set rs=conn.Execute(sql)
			if not rs.eof then
				'验证重名
				dim cenfun
				sql = "select username from cmp_user where username='"&newusername&"' "
				set cenfun=conn.Execute(sql)
				if cenfun.eof then
					'更新对应的密码
					updatepassword=md5(request.Form("password")+newusername,16)
					conn.execute("update cmp_user set username='"&newusername&"',[password]='"&updatepassword&"' where username='"&username&"'")
					Session(CookieName & "_username") = newusername
					Session(CookieName & "_admin") = newusername
					SucMsg="修改成功！"
					Cenfun_suc("manage.asp?action=userinfo")
				else
					ErrMsg = "您输入的用户名已经存在，请返回重试"
					cenfun_error()
				end if
				cenfun.close
				set cenfun=nothing
			else
				ErrMsg = "您输入的原密码错误，请返回重试"
				cenfun_error()
			end if
			rs.close
			set rs=nothing
		else
			ErrMsg = "用户名没有任何变化"
			cenfun_error()
		end if
	end if
end if
end sub


sub main()
sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4"
set rs = conn.execute(sql)
if not rs.eof then
	dim cmp_url,cmp_page_url
	cmp_url = getCmpUrl(rs("id"))
	cmp_page_url = getCmpPageUrl(rs("id"))
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <td width="20%" align="right">CMP调用地址：</td>
    <td width="80%"><a href="<%=cmp_url%>&" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_url%></strong></a></td>
  </tr>
  <tr>
    <td align="right">页面地址：</td>
    <td><a href="<%=cmp_page_url%>" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_page_url%></strong></a></td>
  </tr>
  <tr>
    <td align="right">常用论坛调用标签：</td>
    <td><div style="margin:10px 0px;"><span style="border:1px dashed #00CCFF; padding:5px 5px;">[flash=100%,600]<%=cmp_url%>[/flash]</span></div></td>
  </tr>
  <tr>
    <td align="right">HTML调用代码：</td>
    <td><textarea style="width:99%;" rows="15" onfocus="this.select();"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0" name="cmp" width="100%" height="600" id="cmp">
  <param name="movie" value="<%=cmp_url%>" />
  <param name="quality" value="high" />
  <param name="allowFullScreen" value="true" />
  <param name="allowScriptAccess" value="always" />
  <param name="flashvars" value="" />
  <embed src="<%=cmp_url%>" width="100%" height="600" quality="high" pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" flashvars="" name="cmp"></embed>
</object>
</textarea></td>
  </tr>
</table>
<%
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
end sub
%>
