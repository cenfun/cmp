<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
'检测用户是否登录
If founduser Then
	Select Case Request.QueryString("handler")
		Case "savelistdata"
			savelistdata()
		Case "saveconfigdata"
			saveconfigdata()
		Case "getskins"
			getskins()
		Case "getplugins"
			getplugins()
		Case Else
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
	 End Select
else 
	response.Redirect("index.asp")
end if

sub getskins()
addUTFBOM()
dim userid,cmp_show_url
userid = Session(CookieName & "_userid")
cmp_show_url = getCmpUrl(userid)
dim skinlist
skinlist = "<cmp_skins>"
sql = "select * from cmp_skins order by id desc"
set rs = conn.execute(sql)
if not rs.eof then
	Do Until rs.EOF
		'<skin src="skins/wmp11.zip" mixer_id="" mixer_color="" show_tip="" />
		skinlist = skinlist & "<skin title=""" & XMLEncode(rs("title")) & """ "
		skinlist = skinlist & "preview=""" & cmp_show_url & "&amp;skin_src=" & XMLEncode(rs("src")) & """ "
		skinlist = skinlist & "src=""" & XMLEncode(rs("src")) & """ "
		skinlist = skinlist & "mixer_id=""" & XMLEncode(rs("mixer_id")) & """ "
		skinlist = skinlist & "mixer_color=""" & XMLEncode(rs("mixer_color")) & """ "
		skinlist = skinlist & "show_tip=""" & XMLEncode(rs("show_tip")) & """ />"
	rs.MoveNext
    loop
end if
rs.close
set rs = nothing
skinlist = skinlist & "</cmp_skins>"
Response.Write(skinlist)
end sub

sub getplugins()
addUTFBOM()
dim pluginlist
pluginlist = "<cmp_plugins>"
sql = "select * from cmp_plugins order by id desc"
set rs = conn.execute(sql)
if not rs.eof then
	Do Until rs.EOF
		'<plugin name="大背景" xywh="0, 0, 100P, 100P" src="plugins/bigbg.swf" lock="1" display="1" istop="0" />
		pluginlist = pluginlist & "<plugin title=""" & XMLEncode(rs("title")) & """ "
		pluginlist = pluginlist & "src=""" & XMLEncode(rs("src")) & """ "
		pluginlist = pluginlist & "xywh=""" & XMLEncode(rs("xywh")) & """ "
		pluginlist = pluginlist & "lock=""" & rs("lock") & """ "
		pluginlist = pluginlist & "display=""" & rs("display") & """ "
		pluginlist = pluginlist & "istop=""" & rs("istop") & """ />"
	rs.MoveNext
    loop
end if
rs.close
set rs = nothing
pluginlist = pluginlist & "</cmp_plugins>"
Response.Write(pluginlist)
end sub

sub config()
dim strContent,id
sql = "select id,cmp_name,cmp_url,config from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
	id = rs("id")
	if trim(rs("config"))<>"" then
		strContent = UnCheckStr(rs("config"))
	else
		dim cr
		cr = Chr(13) & Chr(10)  & Chr(13) & Chr(10) 
		strContent = "<cmp name="""" url="""" list="""" >" & cr
		strContent = strContent & "<config language="""" play_mode="""" skin_id="""" list_id="""" volume="""" auto_play="""" max_video="""" "
		strContent = strContent & "mixer_id="""" mixer_color="""" mixer_filter="""" mixer_displace="""" "
		strContent = strContent & "buffer="""" timeout="""" show_tip="""" context_menu="""" video_smoothing="""" plugins_disabled="""" check_policyfile=""""  />" & cr
		strContent = strContent & "<skins>"&cr&"</skins>" & cr 
		strContent = strContent & "<plugins>"&cr&"</plugins>" & cr
		strContent = strContent & "<nolrc src="""">"&cr&"</nolrc>" & cr
		strContent = strContent & "<count src="""&XMLEncode(site_count)&""" />" & cr
		strContent = strContent & "</cmp>"
	end if
	'正则替换配置文件列表地址，名称，网站
	strContent = setLNU(strContent, xml_make, xml_path, xml_list, id, rs("cmp_name"), rs("cmp_url"))
	'更新配置至数据库
	conn.execute("update cmp_user set config='"&CheckStr(strContent)&"' where id=" & id & " ")
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">CMP配置文件编辑: <span style="margin-left:20px;font-weight:normal;">
      <%if request.QueryString("mode")="code" then%>
      <input type="button" onclick="window.location='manage.asp?action=config';" value="&lt;&lt;返回普通编辑模式" />
      <%else%>
      <input type="button" onclick="window.location='manage.asp?action=config&mode=code';" value="进入代码编辑模式&gt;&gt;" />
      <%end if%>
      </span></th>
  </tr>
  <%if request.QueryString("mode")="code" then%>
  <form method="post" action="manage.asp?action=saveconfig" onsubmit="return check_config(this);">
    <tr>
      <td align="center"><textarea name="config" rows="30" id="config" style="width:99%;"><%=strContent%></textarea></td>
    </tr>
    <tr>
      <td align="center"><input name="config_submit" type="submit" id="config_submit" style="width:50px;" value="提交" /></td>
    </tr>
  </form>
  <%else%>
  <tr>
    <td align="center"><script type="text/javascript">
var vars = "";
vars += "i=config.asp%3Fid%3D<%=id%>%26rd%3D"+Math.random();
vars += "&o=manage.asp%3Fhandler%3Dsaveconfigdata";
vars += "&sl=manage.asp%3Fhandler%3Dgetskins%26rd%3D"+Math.random();
vars += "&pl=manage.asp%3Fhandler%3Dgetplugins%26rd%3D"+Math.random();
//id, width, height, cmp url, vars
showcmp("cmp_config_editer", "100%", "600", "CConfig.swf", vars);
</script>
    </td>
  </tr>
  <%end if%>
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
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		config = CheckStr(request.Form("config"))
		conn.execute("update cmp_user set config='"&config&"' where id=" & id & " ")
		SucMsg="修改成功！"
		Cenfun_suc("manage.asp?action=config&mode=code")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_config, UnCheckStr(config))
		end if
	else
		ErrMsg = "用户不存在或者被锁定！"
		cenfun_error()
	end if
	rs.close
	set rs = nothing
end sub

sub saveconfigdata()
	dim config,id
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		config = CheckStr(request.Form("config"))
		conn.execute("update cmp_user set config='"&config&"' where id=" & id & " ")
		Response.Write("CMPConfigComplete")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_config, UnCheckStr(config))
		end if
	end if
	rs.close
	set rs = nothing
end sub

sub list()
dim strContent,id
sql = "select id,list from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
	id = rs("id")
	if trim(rs("list"))<>"" then
		strContent = UnCheckStr(rs("list"))
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
  <tr>
    <th align="left">CMP列表文件编辑: <span style="margin-left:20px;font-weight:normal;">
      <%if request.QueryString("mode")="code" then%>
      <input type="button" onclick="window.location='manage.asp?action=list';" value="&lt;&lt;返回普通编辑模式" />
      <%else%>
      <input type="button" onclick="window.location='manage.asp?action=list&mode=code';" value="进入代码编辑模式&gt;&gt;" />
      <%end if%>
      </span></th>
  </tr>
  <%if request.QueryString("mode")="code" then%>
  <form method="post" action="manage.asp?action=savelist" onsubmit="return check_list(this);">
    <tr>
      <td align="center"><textarea name="list" rows="30" id="list" style="width:99%;"><%=strContent%></textarea></td>
    </tr>
    <tr>
      <td align="center"><input name="list_submit" type="submit" id="list_submit" style="width:50px;" value="提交" /></td>
    </tr>
  </form>
  <%else%>
  <tr>
    <td align="center"><script type="text/javascript">
var vars = "";
vars += "i=list.asp%3Fid%3D<%=id%>%26rd%3D"+Math.random();
vars += "&o=manage.asp%3Fhandler%3Dsavelistdata";
//id, width, height, cmp url, vars
showcmp("cmp_list_editer", "100%", "600", "CList.swf", vars);
</script>
    </td>
  </tr>
  <%end if%>
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
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		list = CheckStr(request.Form("list"))
		conn.execute("update cmp_user set list='"&list&"' where id=" & id & " ")
		SucMsg="修改成功！"
		Cenfun_suc("manage.asp?action=list&mode=code")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_list, UnCheckStr(list))
		end if
	else
		ErrMsg = "用户不存在或者被锁定！"
		cenfun_error()
	end if
	rs.close
	set rs = nothing
end sub

sub savelistdata()
	dim list,id
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		list = CheckStr(request.Form("list"))
		conn.execute("update cmp_user set list='"&list&"' where id=" & id & " ")
		Response.Write("CMPListComplete")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_list, UnCheckStr(list))
		end if
	end if
	rs.close
	set rs = nothing
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
      <td align="right" nowrap="nowrap">最后登录日期：</td>
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
      <td align="right">不公开到用户列表：</td>
      <td><input name="setinfo" type="checkbox" value="1" <%if rs("setinfo")=1 then%>checked="checked"<%end if%> /></td>
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
      <td align="right" nowrap="nowrap">原有密码：</td>
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
      <td align="right" nowrap="nowrap">用户名：</td>
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
	dim email,qq,cmp_name,cmp_url,setinfo,config
	email=Checkstr(Request.Form("email"))
	qq=Checkstr(Request.Form("qq"))
	cmp_name=Checkstr(Request.Form("cmp_name"))
	cmp_url=Checkstr(Request.Form("cmp_url"))
	setinfo=Checkstr(Request.Form("setinfo"))
	if setinfo="" then
		setinfo=0
	end if
	
	set rs = conn.execute("select id,config from cmp_user where username='"&username&"' ")
	'正则替换配置文件列表地址，名称，网站
	config = setLNU(UnCheckStr(rs("config")), xml_make, xml_path, xml_list, rs("id"), cmp_name, cmp_url)
	'重建静态数据
	if xml_make="1" then
		call makeFile(xml_path & "/" & rs("id") & xml_config, config)
	end if
	rs.close
	set rs = nothing
	'保存到数据库
	sql = "update cmp_user set email='"&email&"',qq='"&qq&"',cmp_name='"&cmp_name&"',cmp_url='"&cmp_url&"',setinfo="&setinfo&",config='"&CheckStr(config)&"' where username='"&username&"'"
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
dim userid,cmp_url,cmp_page_url
userid = Session(CookieName & "_userid")
cmp_url = getCmpUrl(userid)
cmp_page_url = getCmpPageUrl(userid)
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <td width="10%" align="right">CMP调用地址：</td>
    <td width="90%"><a href="<%=cmp_url%>&" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_url%></strong></a></td>
  </tr>
  <tr>
    <td align="right">页面地址：</td>
    <td><a href="<%=cmp_page_url%>" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_page_url%></strong></a></td>
  </tr>
  <tr>
    <td align="right" nowrap="nowrap">常用论坛调用标签：</td>
    <td>[flash=100%,600]<%=cmp_url%>[/flash]</td>
  </tr>
  <tr>
    <td align="right" nowrap="nowrap">内框架页面调用：</td>
    <td>&lt;iframe frameborder=&quot;0&quot; scrolling=&quot;no&quot; src=&quot;<%=cmp_page_url%>&quot; width=&quot;100%&quot; height=&quot;600&quot;&gt;&lt;/iframe&gt;</td>
  </tr>
  <tr>
    <td align="right">HTML调用代码：</td>
    <td><textarea id="html_code" name="html_code" style="width:99%;" wrap="virtual" rows="15" onfocus="this.select();"></textarea></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>默认宽100%高600</td>
  </tr>
</table>
<script type="text/javascript">
function show_code() {
	var html = '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,28,0" name="cmp" width="100%" height="600" id="cmp">\n';
	html += '<param name="movie" value="<%=cmp_url%>" />\n';
	html += '<param name="quality" value="high" />\n';
	html += '<param name="allowFullScreen" value="true" />\n';
	html += '<param name="allowScriptAccess" value="always" />\n';
	html += '<param name="flashvars" value="" />\n';
	html += '<embed src="<%=cmp_url%>" width="100%" height="600" quality="high" pluginspage="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" allowfullscreen="true" allowscriptaccess="always" flashvars="" name="cmp"></embed>\n';
	html += '</object>';
	var textarea = document.getElementById("html_code");
	textarea.value = html;
}
show_code();
</script>
<%
end sub
%>
