<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<% 
header()
if Request.QueryString("action")="login" then
	login()
elseif Request.QueryString("action")="logout" then
	logout()
else
	main()
end if
footer()

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
<div> </div>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="420">
  <form action="index.asp?action=login" method="post" onsubmit="return check_login(this);">
    <tr>
      <th colspan="3">用户登录</th>
    </tr>
    <tr>
      <td align="right">用户名：</td>
      <td><input name="username" type="text" id="admin" size="20" tabindex="1" /></td>
      <td>还没有播放器？<a href="index.asp?action=reg" tabindex="5"><span style="font-weight: bold">注册新用户</span></a></td>
    </tr>
    <tr>
      <td align="right">密　码：</td>
      <td><input name="password" type="password" id="password" size="20" tabindex="2" /></td>
      <td><label for="autologin">
        <input type="checkbox" name="autologin" id="autologin" tabindex="6" />
        下次自动登录</label></td>
    </tr>
    <tr>
      <td align="right">验证码：</td>
      <td><input name="verifycode" type="text" id="verifycode" size="6" maxlength="4" tabindex="3" />
        <span class="verifycode"><%=session("verifycode")%></span></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><input name="submit" type="submit" value="登录" style="width:50px;" tabindex="4" /></td>
      <td>&nbsp;</td>
    </tr>
  </form>
</table>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="420">
  <tr>
    <th>相关信息</th>
  </tr>
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<%
end sub

sub goback(msg)
%>
<script type="text/javascript">
alert("<%=msg%>");
window.location = "./";
</script>
<%
end sub

sub login()
	Dim ip,UserName,PassWord
	UserName=Replace(Request("username"),"'","")
	PassWord=md5(request("password"),16)
	If Request("verifycode")="" or Request("verifycode")<>session("verifycode") Then
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
	set rs=conn.Execute("select * from cmp_admin where username='"&username&"' and password='"&PassWord&"'")
	if rs.eof and rs.bof then
		rs.close
		set rs=nothing
		goback("您输入的用户名和密码不正确。")
    	response.End
		Exit Sub
	else
		Session(CookieName & "_flag")="cfmaster"
		Session(CookieName & "_UserName")=Rs("UserName")
		'session超时时间
		Session.Timeout=45
		ip=UserTrueIP
		conn.Execute("Update cmp_admin Set Lasttime="&SqlNowString&",LastIP='"&ip&"' Where UserName='"&UserName&"'")
		rs.close
		set rs=nothing
		Response.Redirect "manage.asp"
	end if	
end sub

function ChkLoginIP(AcceptIP,ChkIp)
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
end function

sub logout()
	Session(CookieName & "_flag")=""
	Response.Redirect("./")
end sub
%>
