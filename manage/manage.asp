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
sql = "select id,list from cmp_user where username = '" & Session(CookieName & "_username") & "' "
set rs = conn.execute(sql)
if not rs.eof then
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=savelist" onsubmit="return check_list(this);">
    <input name="id" type="hidden" value="<%=rs("id")%>" />
    <tr>
      <th align="left">CMP列表文件编辑:</th>
    </tr>
    <tr>
      <td align="center"><textarea name="list" rows="30" id="list" style="width:99%;"><%=rs("list")%></textarea></td>
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
end if
rs.close
set rs = nothing
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
sql = "select id,config from cmp_user where username = '" & Session(CookieName & "_username") & "' "
set rs = conn.execute(sql)
if not rs.eof then
	dim strContent,re
	strContent = rs("config")
	Set re=new RegExp
	re.IgnoreCase =True
	re.Global=True
	re.Pattern="list( *)=( *)\""([^\r]*?)\"""
	if xml_make="1" then
		strContent=re.Replace(strContent,"list=""" & xml_path & "/" & rs("id") & xml_list & """")
	else
		strContent=re.Replace(strContent,"list=""list.asp?id="&rs("id")&"""")
	end if
	
	'名称，网址替换
	
	
	
	Set re=nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveconfig" onsubmit="return check_config(this);">
    <input name="id" type="hidden" value="<%=rs("id")%>" />
    <tr>
      <th align="left">CMP配置文件编辑:</th>
    </tr>
    <tr>
      <td align="center"><textarea name="config" rows="30" id="config" style="width:99%;"><%=strContent%></textarea></td>
    </tr>
    <tr>
      <td align="center"><input name="config_submit" type="submit" id="config_submit" style="width:50px;" value="提交" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_config(o){
	


	return true;
}
</script>
<%
end if
rs.close
set rs = nothing
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
sql = "select * from cmp_user where username = '" & Session(CookieName & "_username") & "' "
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
sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' "
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
    <td align="right">论坛调用代码：</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right">HTML调用代码：</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right">页面地址：</td>
    <td><a href="<%=cmp_page_url%>" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_page_url%></strong></a></td>
  </tr>
</table>
<script type="text/javascript">

</script>
<%
end if
rs.close
set rs = nothing
end sub
















Sub save_manage()
dim saveaction,sql
dim id,classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,hits,addtime,lasttime,isbest,sn
dim addtime_sql,lasttime_sql
	saveaction=request.QueryString("save_manage")
	classid=Request("classid")
		if classid="" then Errmsg=Errmsg&"<li>专辑不能为空!请返回重新填写信息!"
	title=Replace(trim(Request("title")),"'","")
		if title="" then Errmsg=Errmsg&"<li>名称不能为空!请返回重新填写信息!"
	url=Replace(trim(Request("url")),"'","")
		if url="" then Errmsg=Errmsg&"<li>地址不能为空!请返回重新填写信息!"
	lrc=Replace(trim(Request("lrc")),"'","")
	content=Replace(trim(Request("content")),"'","")
	pic=Replace(trim(Request("pic")),"'","")
	x=Replace(trim(Request("x")),"'","")
	y=Replace(trim(Request("y")),"'","")
	w=Replace(trim(Request("w")),"'","")
	h=Replace(trim(Request("h")),"'","")
	s=Replace(trim(Request("s")),"'","")
	a=Replace(trim(Request("a")),"'","")
	c=Replace(trim(Request("c")),"'","")
	u=Replace(trim(Request("u")),"'","")
	scene=Replace(trim(Request("scene")),"'","")
	hits=Replace(trim(Request("hits")),"'","")
	addtime=Request("addtime")
		if IsDate(addtime) then
			addtime_sql="addtime='"&addtime&"',"
		end if
	lasttime=Request("lasttime")
		if IsDate(lasttime) then
			lasttime_sql="lasttime='"&lasttime&"',"
		end if
	isbest=Request("isbest")
		if isbest<>1 then isbest=0
	sn=Replace(trim(Request("sn")),"'","")
		if sn="" then sn=0
if saveaction="edit" then
	saveaction=""
	id=Request("id")
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cfplay_list Set classid="&classid&",title='"&title&"',url='"&url&"',lrc='"&lrc&"',content='"&content&"',pic='"&pic&"',x='"&x&"',y='"&y&"',w='"&w&"',h='"&h&"',s='"&s&"',a='"&a&"',c='"&c&"',u='"&u&"',scene='"&scene&"',isbest="&isbest&","&addtime_sql&""&lasttime_sql&"sn="&sn&" Where id="&id&"")
		SucMsg="<li>修改资料成功!"
		Cenfun_suc("?")
	end if
end if

if saveaction="add" then
	saveaction=""
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		'response.write "classid="&classid&"/url="&url&"/isbest="&isbest
		sql="insert into cfplay_list (classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,addtime,lasttime,isbest,sn) values("&classid&",'"&title&"','"&url&"','"&lrc&"','"&content&"','"&pic&"','"&x&"','"&y&"','"&w&"','"&h&"','"&s&"','"&a&"','"&c&"','"&u&"','"&scene&"',"&SqlNowString&","&SqlNowString&","&isbest&","&sn&")"
		conn.execute(sql)
		SucMsg="<li>添加成功!"
		Cenfun_suc("?")
	end if
end if
end sub

sub save_config()
dim cflist,bg,scene,ads,readme,cfversion,copyright,other
	cflist=request("cflist")
		if cflist="" then Errmsg=Errmsg&"<li>播放列表不能为空!请返回重新填写信息!"
	bg=Request("bg")
		if bg="" then Errmsg=Errmsg&"<li>默认背景不能为空!请返回重新填写信息!"
	scene=Request("scene")
		if scene="" then Errmsg=Errmsg&"<li>默认场景不能为空!请返回重新填写信息!"
	ads=Request("ads")
		if ads="" then Errmsg=Errmsg&"<li>公告不能为空!请返回重新填写信息!"
	readme=Request("readme")		
	cfversion=Request("cfversion")
	copyright=Request("copyright")	
	other=Request("other")
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cfplay_config Set cflist='"&cflist&"',bg='"&bg&"',scene='"&scene&"',ads='"&ads&"',readme='"&readme&"',cfversion='"&cfversion&"',copyright='"&copyright&"',other='"&other&"'")
		SucMsg="<li>修改资料成功!"
		Cenfun_suc("?action=config")
	end if
end sub

Function Checkxml(Str)
	If Isnull(Str) Then
		Checkxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"<","&lt;")
	Str = Replace(Str,">","&gt;")
	Str = Replace(Str,"&","&amp;")
	Str = Replace(Str,"'","&apos;")
	Str = Replace(Str,Chr(34),"&quot;")
	Checkxml = Str
End Function
Function iCheckxml(Str)
	If Isnull(Str) Then
		iCheckxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"&lt;","<")
	Str = Replace(Str,"&gt;",">")
	Str = Replace(Str,"&amp;","&")
	Str = Replace(Str,"&apos;","'")
	'Str = Replace(Str,"&quot;",Chr(34))
	iCheckxml = Str
End Function

function make_file(str,path)
    dim fs,fsowrite
	on error resume next
	Set fs=CreateObject("Scripting.fileSystemObject")
    	Set fsowrite = fs.CreateTextFile(server.MapPath(path),true)
        fsowrite.Write str
        fsowrite.close
		set fsowrite=nothing
	set fs=nothing
	if err.number<>0 then
		response.write "<center>"&Err.Description&"，您的空间不支持FSO，请同您的空间商联系，或者查看相关权限设置。</center>"
	end if
end function

function make_cflist_music(title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene)
	dim str
		str=str&"<m>"
			str=str&"<n>"&Checkxml(title)&"</n>"
			str=str&"<u>"&Checkxml(url)&"</u>"
			str=str&"<c>"&Checkxml(content)&"</c>"
			str=str&"<p"
			if x<>"" then str=str&" x="""&x&""""
			if y<>"" then str=str&" y="""&y&""""
			if w<>"" then str=str&" w="""&w&""""
			if h<>"" then str=str&" h="""&h&""""
			if s<>"" then str=str&" s="""&s&""""
			if a<>"" then str=str&" a="""&a&""""
			if c<>"" then str=str&" c="""&c&""""
			if u<>"" then str=str&" u="""&u&""""
			str=str&">"&Checkxml(pic)&"</p>"
			str=str&"<l>"&Checkxml(lrc)&"</l>"
			str=str&"<s>"&Checkxml(scene)&"</s>"		
		str=str&"</m>"
	make_cflist_music=str	
end function

%>
