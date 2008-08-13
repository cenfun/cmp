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
		If Err.Number=-2147221005 Then 
			ErrMsg = "服务器不支持ADODB.Stream"
			cenfun_error()
			Err.Clear
		else
			With objStream
			.Open
			.Charset = "utf-8"
			.Position = objStream.Size
			.WriteText = list
			.SaveToFile Server.Mappath(xml_path & "/" & id & xml_list),2 
			.Close
			End With
			Set objStream = Nothing
		end if
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
		strContent = "<cmp name="""" url="""" list="""" >" & Chr(13) & Chr(10) & "</cmp>"
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
      <td><div style="padding-top:5px; margin-top:5px; border-top:1px dashed #CCCCCC;">注：其中name,url,list属性会自动根据个人资料和站点设置进行替换</div></td>
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
		If Err.Number=-2147221005 Then 
			ErrMsg = "服务器不支持ADODB.Stream"
			cenfun_error()
			Err.Clear
		else
			With objStream
			.Open
			.Charset = "utf-8"
			.Position = objStream.Size
			.WriteText = config
			.SaveToFile Server.Mappath(xml_path & "/" & id & xml_config),2 
			.Close
			End With
			Set objStream = Nothing
		end if
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
    <td width="80%"><a href="<%=cmp_url%>" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_url%></strong></a></td>
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
