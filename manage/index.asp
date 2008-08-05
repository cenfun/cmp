<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
if Request.QueryString("username")<>"" then
	checkuser()
else
	header()
	Select Case Request.QueryString("action")
	Case "login"
		login()
	Case "reg"
		reg()
	Case "save_reg"
		save_reg()
	Case "logout"
		logout()
	Case Else
		main()
	End Select
	footer()
end if



sub main()
	menu()
	dim rndnum,verifycode,num1
	Randomize
	Do While Len(rndnum)<4
	num1=CStr(Chr((57-48)*rnd+48))
	rndnum=rndnum&num1
	loop
	session("verifycode")=rndnum
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="700">
  <form action="index.asp?action=login" method="post" onsubmit="return check(this);">
    <tr>
      <th colspan="2">用户登录</th>
    </tr>
    <tr>
      <td align="right">用户名：</td>
      <td><input name="username" type="text" id="username" size="25" tabindex="1" />
        还没有CMP？<a href="index.asp?action=reg" tabindex="5"><span style="font-weight: bold">免费注册新用户</span></a></td>
    </tr>
    <tr>
      <td align="right">密　码：</td>
      <td><input name="password" type="password" id="password" size="25" tabindex="2" />
        忘记密码？联系管理员(<a href="mailto:<%=site_email%>" title="<%=site_email%>" target="_blank">邮箱</a>或<a href="http://wpa.qq.com/msgrd?V=1&Uin=<%=site_qq%>&Exe=QQ&Site=<%=site_url%>&Menu=No" title="<%=site_qq%>" target="_blank">QQ</a>)</td>
    </tr>
    <tr>
      <td align="right">验证码：</td>
      <td><input name="verifycode" type="text" id="verifycode" size="6" maxlength="4" tabindex="3" />
        <span class="verifycode"><%=session("verifycode")%></span></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><input name="submit" type="submit" value="登录" style="width:50px;" tabindex="4" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check(o){
	if(o.username.value==""){
		alert("用户名不能为空！");
		o.username.focus();
		return false;
	}
	if(o.password.value==""){
		alert("用户密码不能为空！");
		o.password.focus();
		return false;
	}
	if(o.verifycode.value==""){
		alert("验证码不能为空！");
		o.verifycode.focus();
		return false;
	}
	return true;
}
</script>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="700">
  <tr>
    <th>系统公告</th>
  </tr>
  <tr>
    <td><%=site_ads%></td>
  </tr>
</table>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="700">
  <tr>
    <th>相关信息</th>
  </tr>
  <tr>
    <td><ul class="list">
        <li>晨风在线音乐系统通过与 <a href="http://bbs.cenfun.com/" target="_blank">CMP v3.0</a> 的结合，可以轻松实现网上音乐的在线编辑和播放，并支持多用户管理，让你轻松建设自己的多用户音乐站</li>
        <li>管理员的默认帐号和密码为：admin </li>
        <li>安全起见，请在第一次登录后将管理员的用户名或密码修改，请在conn.asp文件中对数据库路径和名称进行修改(默认为data/#cmp3_2008.mdb，推荐数据库文件名中加#符号，防止被猜测下载)，进入系统请根据情况修改您的站点配置信息</li>
        <li>管理员可以开启和关闭用户注册，以及用户注册后是否需要审核，并管理所有用户；管理员可以管理预存皮肤skins和插件plugins，以供普通用户选择使用</li>
        <li>普通用户激活后(审核通过)，可以登录系统管理自己的配置config和列表list，修改用户信息以及获得播放器调用地址</li>
        <li>更多信息请进CMP交流论坛:<a href="http://bbs.cenfun.com/" target="_blank">http://bbs.cenfun.com/</a></li>
      </ul></td>
  </tr>
</table>
<%
end sub

sub reg()
	menu()
if user_reg="1" then
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="700">
  <form action="index.asp?action=save_reg" method="post" onsubmit="return check(this);">
    <tr>
      <th colspan="2">用户注册</th>
    </tr>
    <tr>
      <td align="right">用户名：</td>
      <td><input name="username" type="text" id="username" size="30" maxlength="200" onchange="check_username(this)" />
        <span id="reg_username" style="color:#FF0000;"></span></td>
    </tr>
    <tr>
      <td align="right">密码：</td>
      <td><input name="password" type="password" id="password" size="30" /></td>
    </tr>
    <tr>
      <td align="right">确认密码：</td>
      <td><input name="passwordcheck" type="password" id="passwordcheck" size="30" /></td>
    </tr>
    <tr>
      <td align="right">邮箱：</td>
      <td><input name="email" type="text" id="email" size="30" maxlength="50" /></td>
    </tr>
    <tr>
      <td align="right">QQ：</td>
      <td><input name="qq" type="text" id="qq" size="30" maxlength="50" /></td>
    </tr>
    <%if user_check="1" then%>
    <tr>
      <td align="right">注：</td>
      <td>系统开启了新注册用户需要审核，请如实填写您的注册信息</td>
    </tr>
    <%end if%>
    <tr>
      <td>&nbsp;</td>
      <td><input name="submit" type="submit" value="提交" style="width:50px;" tabindex="4" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
var username_err = "";
var ru = document.getElementById("reg_username");
function check_username(o){
	username_err = "";
	var un = o.value;
	if(un.length < 3){
		username_err = "用户名的长度不能小于3";
		ru.innerHTML = username_err;
		return;
	}
	//检测是否已经存在
	ajaxSend("GET","index.asp?rd="+Math.round()+"&username="+un,true,null,completeHd,errorHd)
}
function completeHd(data){
	//alert(data);
	if(data != ""){
		username_err = data;
		ru.innerHTML = username_err;
	} else {
		ru.innerHTML = "";
	}
}
function errorHd(errmsg){
	alert(errmsg);
}
function check(o){
	if(o.username.value==""){
		alert("用户名不能为空！");
		o.username.focus();
		return false;
	}
	if (username_err!=""){
		alert(username_err);
		o.username.select();
		return false;
	}
	if(o.password.value==""){
		alert("用户密码不能为空！");
		o.password.focus();
		return false;
	}
	if(o.passwordcheck.value==""){
		alert("确认密码不能为空！");
		o.passwordcheck.focus();
		return false;
	}
	if(o.password.value!=o.passwordcheck.value){
		alert("确认密码和密码不一致，请重新输入！");
		o.password.focus();
		o.password.value = "";
		o.passwordcheck.value = "";
		return false;
	}
	return true;
}
</script>
<%
else
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="700">
  <tr>
    <th>用户注册</th>
  </tr>
  <tr>
    <td align="center">站点暂时关闭用户注册。如有任何问题，请查看<a href="index.asp">系统公告</a>或联系管理员：<br />
      邮箱：<a href="mailto:<%=site_email%>" title="<%=site_email%>" target="_blank"><%=site_email%></a><br />
      QQ：<a href="http://wpa.qq.com/msgrd?V=1&Uin=<%=site_qq%>&Exe=QQ&Site=<%=site_url%>&Menu=No" title="<%=site_qq%>" target="_blank"><%=site_qq%></a></td>
  </tr>
</table>
<%
end if
end sub

sub checkuser()
	set rs=conn.Execute("select * from cmp_user where username='"&Checkstr(Request.QueryString("username"))&"'")
	if not rs.eof then
    	response.Write("用户名已经存在")
	end if
	rs.close
	set rs=nothing
end sub

sub save_reg()


end sub



sub goback(msg)
%>
<script type="text/javascript">
alert("<%=msg%>");
window.location = "index.asp";
</script>
<%
end sub

sub login()
	Dim UserName,PassWord,verifycode
	UserName=Checkstr(Request.Form("username"))
	PassWord=md5(request.Form("password")+UserName,16)
	verifycode=Checkstr(Request.Form("verifycode"))
	If verifycode="" or verifycode<>session("verifycode") Then
		session("verifycode")=""
		goback("验证码输入有误！请重新输入正确的信息。")
    	response.End
		Exit Sub
	Elseif 	session("verifycode")="" then
		goback("请不要重复提交，如需重新登陆请返回登陆页面。")
    	response.End
		Exit Sub
	End If
	Session("verifycode")=""
	set rs=conn.Execute("select * from cmp_user where username='"&UserName&"' and password='"&PassWord&"'")
	if rs.eof and rs.bof then
		rs.close
		set rs=nothing
		goback("您输入的用户名和密码不正确。")
    	response.End
		Exit Sub
	else
		'session超时时间
		Session.Timeout=45
		Session(CookieName & "_username")=UserName
		if rs("isadmin") = "1" then
			Session(CookieName & "_admin")="cmp_admin"
		else
			Session(CookieName & "_admin")=""
		end if
		sql = "Update cmp_user Set Lasttime="&SqlNowString&",Lastip='"&UserTrueIP&"' Where username='"&UserName&"'"
		'response.Write(sql)
		conn.Execute(sql)
		rs.close
		set rs=nothing
		Response.Redirect "manage.asp"
	end if	
end sub

sub logout()
	Session(CookieName & "_username")=""
	Session(CookieName & "_admin")=""
	Response.Redirect("index.asp")
end sub
%>
