<!--#include file="conn.asp"-->
<!--#include file="md5.asp"-->
<!--#include file="head.asp"-->
<% 
if request("action")="chk" then
call ChkLogin()
elseif request("action")="out" then
call logout()
end if
dim rndnum,verifycode,num1
Randomize
Do While Len(rndnum)<4
num1=CStr(Chr((57-48)*rnd+48))
rndnum=rndnum&num1
loop
session("verifycode")=rndnum
%>

<table width="600" height="50" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<table width="600" border=0 align=center cellpadding=0 cellspacing=0 class="shadow">
  <tr>
    <th height="24" valign=middle>CenFun Music Player Manage</th>
  </tr>
  <tr>
    <td valign=middle height=25><table width="100%" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td width="65%" height="200" bgcolor="#F1F3F5">
            <table width="300" height="138" border="0" align="center" cellpadding="0" cellspacing="1" bgcolor="#CCCCCC">
              <tr>
                <td valign="top" bgcolor="#F1F3F5"><table width="300" border="0" cellpadding="0" cellspacing="0">
				<form name="form1" method="post" action="?action=chk" target="_top">
                    <tr>
                      <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                      <td height="26" align="right" class="text">用户名：</td>
                      <td height="26"><input name="username" type="text" id="admin" size="20" style="width:150;"></td>
                    </tr>
                    <tr>
                      <td height="26" align="right" class="text">密　码：</td>
                      <td height="26"><input name="password" type="password" id="password" size="20" style="width:150;"></td>
                    </tr>
                    <tr>
                      <td height="26" align="right" class="text">验证码：</td>
                      <td height="26"><input name="verifycode" type="text" id="verifycode" size="6" maxlength="4">
                      <span style="FONT-SIZE: 14px; color:#FF0000; background-color: #CCCCCC; width:50;"><strong>&nbsp;<%=session("verifycode")%></strong></span></td>
                    </tr>
                    <tr align="center">
                      <td height="40" colspan="2"><input  onClick="return check()"; name="Submit" type="image" value="提交" src="images/login_button.gif" width="69" height="20"></td>
                    </tr>
				</form>
                </table></td>
              </tr>
            </table>
          </td>
          <td width="2%" bgcolor="#F1F3F5"><br></td>
          <td width="33%" align="center" bgcolor="#E4EDF9"><img src="images/cms_login.gif" width="190" height="114"></td>
        </tr>
    </table></td>
  </tr>
</table>
</body>
</html>
<script LANGUAGE="javascript">
<!--
document.form1.admin.focus();
function checkspace(checkstr) {
  var str = '';
  for(i = 0; i < checkstr.length; i++) {
    str = str + ' ';
  }
  return (str == checkstr);
}
function check()
{
  if(checkspace(document.form1.admin.value)) {
	document.form1.admin.focus();
    alert("用户名不能为空！");
	return false;
  }
  if(checkspace(document.form1.password.value)) {
	document.form1.password.focus();
    alert("密码不能为空！");
	return false;
  }
    if(checkspace(document.form1.verifycode.value)) {
	document.form1.verifycode.focus();
    alert("请输入验证码！");
	return false;
  }
	return true;
  }
//-->
</script> 
<%
Sub ChkLogin()
	Dim ip
	Dim UserName
	Dim PassWord
	UserName=Replace(Request("username"),"'","")
	PassWord=md5(request("password"),16)
	If Request("verifycode")="" or Request("verifycode")<>session("verifycode") Then
		session("verifycode")=""
		response.Write "<script language=javascript>alert('验证码输入有误！返回后请刷新登录页面后重新输入正确的信息。');document.location='login.asp';</script>"
    	response.End
		Exit Sub
	Elseif 	session("verifycode")="" then
		response.Write "<script language=javascript>alert('请不要重复提交，如需重新登陆请返回登陆页面。');document.location='login.asp';</script>"
    	response.End
		Exit Sub
	End If
	Session("verifycode")=""
	set rs=conn.Execute("select * from cfadmin where username='"&username&"' and password='"&PassWord&"'")
	if rs.eof and rs.bof then
		rs.close
		set rs=nothing
		response.Write "<script language=javascript>alert('您输入的用户名和密码不正确。');document.location='login.asp';</script>"
    	response.End
		Exit Sub
	else
		Session(CookieName & "_flag")="cfmaster"
		Session(CookieName & "_UserName")=Rs("UserName")
		'session超时时间
		Session.Timeout=45
		ip=UserTrueIP
		conn.Execute("Update cfadmin Set Lasttime="&SqlNowString&",LastIP='"&ip&"' Where UserName='"&UserName&"'")
		rs.close
		set rs=nothing
		Response.Redirect "manage.asp"
	end if	
End Sub

Function ChkLoginIP(AcceptIP,ChkIp)
	Dim i,LoginIP,TempIP
	ChkLoginIP = False
	If Instr("|"&AcceptIP&"|","|"&ChkIp&"|") Then ChkLoginIP = True : Exit Function
	LoginIP = Split(ChkIp,".")
	TempIP = LoginIP(0)&"."&LoginIP(1)&"."&LoginIP(2)&".*"
	If Instr("|"&AcceptIP&"|","|"&TempIP&"|") Then ChkLoginIP = True : Exit Function
	TempIP = LoginIP(0)&"."&LoginIP(1)&".*.*"
	If Instr("|"&AcceptIP&"|","|"&TempIP&"|") Then ChkLoginIP = True : Exit Function
	TempIP = LoginIP(0)&".*.*.*"
	If Instr("|"&AcceptIP&"|","|"&TempIP&"|") Then ChkLoginIP = True : Exit Function
End Function

sub logout()
	Session(CookieName & "_flag")=""
	Response.Redirect("../")
end sub
%>