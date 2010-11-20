<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
site_title = "管理中心"
'检测用户是否登录
If founduser Then
	Select Case Request.QueryString("handler")
		Case "getskins"
			getskins()
		Case "getplugins"
			getplugins()
		Case Else
			header()
			menu()
			top_menu()
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
	header()
	ErrMsg = "用户未登录或超时退出，请<a href=""index.asp"">重新登录</a>！"
	cenfun_error()
end if

sub top_menu()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder menu_bar" width="98%">
  <tr>
    <td><div class="clearfix">
        <div class="lt"><a href="manage.asp">调用代码</a></div>
        <div class="lt"><a href="manage.asp?action=config">配置管理</a></div>
        <div class="lt"><a href="manage.asp?action=list">列表管理</a></div>
      </div></td>
  </tr>
</table>
<%
end sub	


sub getskins()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
  <tr>
    <th>皮肤名称</th>
    <th>配置代码</th>
  </tr>
  <%
	'所有皮肤
	sql = "select * from cmp_skins order by id desc"
	set rs = conn.execute(sql)
	Do Until rs.EOF
  %>
  <tr align="center" onmouseover="highlight(this,'#F9F9F9');">
    <td align="right" nowrap="nowrap"><%=trim(rs("title"))%></td>
    <td><input type="text" value="skin=&quot;<%=trim(rs("src"))%>&quot;" onfocus="this.select()" style="width:98%;" /></td>
  </tr>
  <%
	rs.MoveNext
	loop
	rs.close
	set rs = nothing
  %>
  <tr>
    <td>&nbsp;</td>
    <td>如果需要预载多个皮肤，请用skins=&quot;&quot; 中间用英文逗号隔开</td>
  </tr>
</table>
<%
end sub

sub getplugins()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
  <tr>
    <th>插件名称</th>
    <th>配置代码</th>
  </tr>
  <%
	sql = "select * from cmp_plugins order by id desc"
	set rs = conn.execute(sql)
	Do Until rs.EOF
  %>
  <tr align="center" onmouseover="highlight(this,'#F9F9F9');">
    <td align="right" nowrap="nowrap"><%=trim(rs("title"))%></td>
    <td><input type="text" value="plugins=&quot;<%=trim(rs("src"))%>&quot;" onfocus="this.select()" style="width:98%;" /></td>
  </tr>
  <%
	rs.MoveNext
	loop
	rs.close
	set rs = nothing
  %>
  <tr>
    <td>&nbsp;</td>
    <td>如果想在背景层加载，请用backgrounds=&quot;&quot;<br />
      多个插件可以用英文逗号隔开<br />
      某些插件可能需要在配置传入专属参数，需参见插件的具体使用说明<br />
      如果需要设置插件显示类特殊参数，请参见CMP相关使用说明</td>
  </tr>
</table>
<%
end sub



sub config()
dim id,cmp_name,cmp_url,config_xml
id = Session(CookieName & "_userid")
if IsNumeric(id) then
	sql = "select cmp_name,cmp_url,config from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		cmp_name=rs("cmp_name")
		cmp_url=rs("cmp_url")
		config_xml=rs("config")
	end if
	rs.close
	set rs=nothing
end if
%>
<script type="text/javascript" src="js/cmpvars.js"></script>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveconfig" onsubmit="return check_config(this);">
    <tr>
      <th colspan="2" align="left">CMP配置文件编辑: </th>
    </tr>
    <tr>
      <td valign="top" width="60%"><textarea name="config" rows="20" id="config_area" class="xml_area" style="width:98%;"><%=config_xml%></textarea></td>
      <td valign="top"><div>
          <div>配置内容的XML格式要求：</div>
          <div class="xml">&lt;cmp<br />
            <span class="red">lists=&quot;list.asp?id=<%=id%>&quot;</span><br />
            name=&quot;<%=cmp_name%>&quot;<br />
            link=&quot;<%=cmp_url%>&quot;<br />
            description=&quot;Welcome to CMP&quot;<br />
            skin=&quot;&quot;<br />
            plugins=&quot;plugins/sharing.swf&quot;<br />
            backgrounds=&quot;plugins/announce.swf&quot;<br />
            logo=&quot;{src:images/logo.png,xywh:[5,5,0,0]}&quot;<br />
            play_mode=&quot;&quot;<br />
            auto_play=&quot;&quot;<br />
            counter=&quot;<%=site_count%>&quot;<br />
            /&gt;</div>
          <div>参数转义工具：<a href="http://tools.cenfun.com/" target="_blank">http://tools.cenfun.com/</a></div>
        </div></td>
    </tr>
    <tr>
      <td valign="top"><div class="clearfix">
          <div class="lt">
            <input type="submit" style="width:50px;" value="提交" />
            <input type="button" style="width:50px;" onclick="check_xml(this);" value="检测" />
            <input type="button" style="width:50px;" onclick="preview(this);" value="预览" />
          </div>
          <div class="rt">
            <input type="button" style="width:70px;" onclick="showList('skins')" value="选择皮肤" />
            <input type="button" style="width:110px;" onclick="showList('plugins')" value="选择插件或背景" />
          </div>
        </div>
        <div class="area_skins" style="display:none;margin-top:8px;"></div>
        <div class="area_plugins" style="display:none;margin-top:8px;"></div></td>
      <td valign="top"><div>
          <input type="button" value="所有配置支持的参数" onclick="show_vars('config', '.vars_list')" />
        </div>
        <div class="vars_list" style="display:none;"></div></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function showList(type) {
	var o = $(".area_" + type);
	if (type == "skins") {
		$(".area_plugins").slideUp();
	} else {
		$(".area_skins").slideUp();
	}
	
	if (o.html()) {
		o.slideToggle();
	} else {
		o.html(loading).show();
		$.get("manage.asp?handler=get" + type, function(data) {
			o.hide().html(data).slideDown();
		});
	}
}

function check_xml(o) {
	if (check_config(o.form)) {
		alert("XML格式正确！");
	}
}
function check_config(o){
	var str = o.config.value;
	var chk = checkXML(str);
	var isok = chk[0];
	var xmlDoc = chk[1];
	//检测列表是否为空
	if (isok) {
		var root = xmlDoc.documentElement;
	}
	return isok;
}
function preview(o) {
	if (check_config(o.form)) {
		var str = encodeURIComponent(o.form.config.value);
		window.open("<%=getCmpPath()%>?config=" + str);
	}	
}
</script>
<%
end sub

'从Form保存
sub saveconfig()
	dim config,id
	id = Session(CookieName & "_userid")
	config = Request.Form("config")
	conn.execute("update cmp_user set config='"&CheckStr(config)&"' where userstatus > 4 and id=" & id & " ")
	'重建静态数据
	if xml_make="1" then
		call makeFile(xml_path & "/" & id & xml_config, config)
	end if
	SucMsg="修改配置成功！"
	Cenfun_suc("manage.asp?action=config")
end sub



sub list()
dim id
id = Session(CookieName & "_userid")
%>
<script type="text/javascript" src="js/cmpvars.js"></script>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=savelist" onsubmit="return check_list(this);">
    <tr>
      <th align="left" colspan="2">CMP列表文件编辑: </th>
    </tr>
    <tr>
      <td valign="top" width="60%"><textarea name="list" rows="30" id="list_area" class="xml_area" style="width:98%;"><%=getList(id)%></textarea></td>
      <td valign="top"><div>
          <div>列表内容的XML格式要求：</div>
          <div class="xml">&lt;list&gt;<br />
            &lt;m type=&quot;&quot; src=&quot;music/test.mp3&quot; lrc=&quot;&quot; label=&quot;MP3音乐&quot; /&gt;<br />
            &lt;m type=&quot;&quot; src=&quot;music/test.flv&quot; lrc=&quot;&quot; label=&quot;FLV视频&quot; /&gt;<br />
            &lt;/list&gt;</div>
          <div>参数转义工具：<a href="http://tools.cenfun.com/" target="_blank">http://tools.cenfun.com/</a></div>
          <div>
          <input type="button" value="所有列表支持的参数" onclick="show_vars('list', '.vars_list')" />
        </div>
        <div class="vars_list" style="display:none;"></div>
        </div></td>
    </tr>
    <tr>
      <td valign="top"><input name="list_submit" type="submit" style="width:50px;" value="提交" />
        <input name="list_check" type="button" style="width:50px;" onclick="check_xml(this);" value="检测" />
        注意：列表生效必须在配置中添加 <b class="red">lists=&quot;list.asp?id=<%=id%>&quot;</b></td>
      <td valign="top">&nbsp;</td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_xml(o) {
	if (check_list(o.form)) {
		alert("XML格式正确！");
	}
}
function check_list(o){
	var str = o.list.value;
	var chk = checkXML(str);
	var isok = chk[0];
	return isok;
}
</script>
<%
end sub


sub savelist()
	dim list,id
	id = Session(CookieName & "_userid")
	list = Request.Form("list")
	conn.execute("update cmp_user set list='"&CheckStr(list)&"' where userstatus > 4 and id=" & id & " ")
	'重建静态数据
	if xml_make="1" then
		call makeFile(xml_path & "/" & id & xml_list, list)
	end if
	SucMsg="修改列表成功！"
	Cenfun_suc("manage.asp?action=list")
end sub



sub userinfo()
sql = "select * from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveinfo&amp;do=info" onsubmit="return check_info(this);">
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
  <form method="post" action="manage.asp?action=saveinfo&amp;do=pass" onsubmit="return check_pass(this);">
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
	if(o.qq.value!=""){
		if(isNaN(o.qq.value)){
			alert("QQ号码必须为数字！");
			o.qq.select();
			return false;
		}
	}
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
  <form method="post" action="manage.asp?action=saveinfo&amp;do=name" onsubmit="return check_name(this);">
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
	if setinfo<>"" then
		setinfo=1
	else
		setinfo=0
	end if
	
	set rs = conn.execute("select id,config from cmp_user where username='"&username&"' ")
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
<table border="0" cellpadding="3" cellspacing="2" class="tableborder" width="98%">
  <tr>
    <th colspan="2" align="left">调用代码：</th>
  </tr>
  <tr>
    <td align="right" width="10%">CMP调用地址：</td>
    <td width="90%"><input type="text" value="<%=cmp_url%>" onfocus="this.select();" style="width:99%;" />
      <a href="<%=cmp_url%>" target="_blank" title="点击在新窗口中打开">打开预览</a></td>
  </tr>
  <tr>
    <td align="right">Web页面地址：</td>
    <td><input type="text" value="<%=cmp_page_url%>" onfocus="this.select();" style="width:99%;" />
      <a href="<%=cmp_page_url%>" target="_blank" title="点击在新窗口中打开">打开预览</a></td>
  </tr>
  <tr>
    <td align="right" nowrap="nowrap">UBB调用标签：</td>
    <td><input type="text" value="[flash=600,400]<%=cmp_url%>[/flash]" onfocus="this.select();" style="width:99%;" /></td>
  </tr>
  <tr>
    <td align="right" nowrap="nowrap">内框架页面调用：</td>
    <td><input type="text" value="&lt;iframe frameborder=&quot;0&quot; scrolling=&quot;no&quot; src=&quot;<%=cmp_page_url%>&quot; width=&quot;600&quot; height=&quot;400&quot;&gt;&lt;/iframe&gt;" onfocus="this.select();" style="width:99%;" /></td>
  </tr>
  <tr>
    <td align="right">HTML调用代码：</td>
    <td><textarea id="html_code" name="html_code" style="width:99%;" wrap="virtual" rows="5" onfocus="this.select();"></textarea></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>注意：上面的宽高设置为600x400，请自行修改</td>
  </tr>
</table>
<script type="text/javascript">
function show_code() {
	html = getcmp("cmp<%=userid%>", "600", "400", "<%=cmp_url%>", "");
	var textarea = document.getElementById("html_code");
	textarea.value = html;
}
show_code();
</script>
<%
end sub
%>
