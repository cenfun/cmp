<!--#include file="conn.asp"-->
<!--#include file="md5.asp"-->
<!--#include file="head.asp"-->
<%
If Session(CookieName & "_flag")="" Then
	ErrMsg=ErrMsg&"<li>超时退出或者尚未登录！请退出或重新<a href=login.asp target=_top>登录</a>页面。"
	Cenfun_error()
end if
Select Case Request("action")
Case "savepass"
	Call savepass()
Case Else
	Call main()
End Select
If Errmsg<>"" Then cenfun_error()
Call Footer()

sub savepass()
	Dim UserName,ip
	Dim PassWord,PassWord1
	UserName=Replace(Request("username"),"'","")
	PassWord=md5(request("password"),16)
	PassWord1=md5(request("password1"),16)
	ip=UserTrueIP
	set rs=conn.Execute("select * from cfadmin where password='"&PassWord&"'")
	if rs.eof then
		rs.close
		set rs=nothing
		Errmsg=Errmsg&"<li>原密码不正确,修改失败！"
		cenfun_error()
    	response.End
		Exit Sub
	else
		rs.close
		set rs=nothing
		'Response.write PassWord1
		conn.Execute("Update cfadmin Set username='"&UserName&"',[password]='"&password1&"',Lasttime="&SqlNowString&",LastIP='"&ip&"' ")
		Session(CookieName & "_UserName")=UserName
		'session超时时间
		Session.Timeout=45
		SucMsg=SucMsg&"<li>修改密码成功！"
		Cenfun_suc("?")
	end if	
end sub

sub main()
%>
<table border="0" cellspacing="1" cellpadding="5" align="center" width="95%" class="tableBorder">
  <form action="?action=savepass" method="post" name="form_user_pass" id="form_user_pass">
    <tr>
      <th colspan="4" align="center" id="TableTitleLink">管理用户密码修改</th>
    </tr>
    <tr>
      <td class="cmsRow" align="right"><strong>旧密码：</strong></td>
      <td class="cmsRow"><input name="password" type="password" id="password" size="15" />
          <font color="red">*</font></td>
    </tr>
    <tr>
      <td class="cmsRow" align="right"><strong>用户名：</strong></td>
      <td class="cmsRow"><input name="username" type="text" value="<%=Session(CookieName & "_UserName")%>" /></td>
    </tr>
    <tr>
      <td class="cmsRow" align="right"><strong>新密码：</strong></td>
      <td class="cmsRow"><input name="password1" type="password" id="password1" size="15" />
          <font color="red">*</font></td>
    </tr>
    <tr>
      <td class="cmsRow" align="right"><strong>新密码确认：</strong></td>
      <td class="cmsRow"><input name="password2" type="password" id="password2" size="15" />
          <font color="red">*</font></td>
    </tr>
    <tr>
      <td class="cmsRow" colspan="4" align="center"><input type="submit" class="button" name="submit_user_pass" value=" 修 改 " onclick="return check();" />
      </td>
    </tr>
  </form>
</table>
<script language="JavaScript" type="text/javascript">
<!--
function checkspace(checkstr) {
  var str = '';
  for(i = 0; i < checkstr.length; i++) {
    str = str + ' ';
  }
  return (str == checkstr);
}
function check()
{
  if(checkspace(document.form_user_pass.username.value)) {
	document.form_user_pass.username.focus();
    alert("用户名不能为空！");
	return false;
  }
  if(checkspace(document.form_user_pass.password.value)) {
	document.form_user_pass.password.focus();
    alert("旧密码不能为空！");
	return false;
  }
  if(checkspace(document.form_user_pass.password1.value)) {
	document.form_user_pass.password1.focus();
    alert("新密码不能为空！");
	return false;
  }
    if(checkspace(document.form_user_pass.password2.value)) {
	document.form_user_pass.password2.focus();
    alert("确认密码不能为空！");
	return false;
  }
    if(document.form_user_pass.password1.value != document.form_user_pass.password2.value) {
	document.form_user_pass.password1.focus();
	document.form_user_pass.password1.value = '';
	document.form_user_pass.password2.value = '';
    alert("新密码和确认密码不相同，请重新输入");
	return false;
  }
	document.form_user_pass.submit();
  }
//-->
</script>
<%
end sub
%>
