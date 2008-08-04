<%
Dim Arr_system_info
IF Not IsArray(Application(CookieName&"_Arr_system_info")) Then
	set rs=conn.Execute("select * from cmp_config")
	If rs.EOF And rs.BOF Then
		Redim Arr_system_info(2,0)
	Else
		Arr_system_info=rs.GetRows
	End If
	rs.Close
	Set rs=Nothing
	Application.Lock
	Application(CookieName&"_Arr_system_info")=Arr_system_info
	Application.UnLock
End IF

Arr_system_info=Application(CookieName&"_Arr_system_info")
Dim site_name,site_url,site_email
'站点名称
site_name = Arr_system_info(0,0)
'站点网站
site_url = Arr_system_info(1,0)
'管理员邮箱
site_email = Arr_system_info(2,0)

dim UserTrueIP
UserTrueIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
If UserTrueIP = "" Then UserTrueIP = Request.ServerVariables("REMOTE_ADDR")

'检测用户登录
function passport()
	If Session(CookieName & "_username")="" Then
		response.Redirect("index.asp")
	end if
end function
'过滤SQL非法字符
Function Checkstr(Str)
	If Isnull(Str) Then
		CheckStr = ""
		Exit Function 
	End If
	Str = Replace(Str,Chr(0),"")
	CheckStr = Replace(Str,"'","''")
End Function

Sub showpage(language,format,sfilename,totalnumber,MaxPerPage,ShowTotal,ShowAllPages,strUnit,CurrentPage)
	dim zh,en,str
	zh="共,首页,上一页,下一页,尾页,页次：,页,页,转到："
	en="Total,First,Previous,Next,Last,Page:,&nbsp;,Page,Turn To:"
	if language="en" then
		str=split(en,",")
	else
		str=split(zh,",")
	end if
	dim n, i,strTemp,strUrl
	if totalnumber mod MaxPerPage=0 then
		n= totalnumber \ MaxPerPage
	else
		n= totalnumber \ MaxPerPage+1
	end if
	strTemp="<table width='100%'>"
	'strTemp=strTemp &  "<tr><td height='1' colspan='2' bgcolor='#4D8BEB'></td></tr>"
	strTemp=strTemp &  "<tr align='right'><td>"
	if ShowTotal=true then 
		strTemp=strTemp&str(0)&" <b>" & totalnumber & "</b> " & strUnit & "&nbsp;&nbsp;"
	end if
	strUrl=JoinChar(sfilename)
	if CurrentPage<2 then
			strTemp=strTemp & str(1)&"&nbsp;"&str(2)&"&nbsp;"
	else
			strTemp=strTemp & "<a href='" & strUrl & "page=1'>"&str(1)&"</a>&nbsp;"
			strTemp=strTemp & "<a href='" & strUrl & "page=" & (CurrentPage-1) & "'>"&str(2)&"</a>&nbsp;"
	end if
	if n-CurrentPage<1 then
			strTemp=strTemp&str(3)&"&nbsp;"&str(4)
	else
			strTemp=strTemp & "<a href='" & strUrl & "page=" & (CurrentPage+1) & "'>"&str(3)&"</a>&nbsp;"
			strTemp=strTemp & "<a href='" & strUrl & "page=" & n & "'>"&str(4)&"</a>"
	end if
	strTemp=strTemp & "&nbsp;"&str(5)&"<strong><font color=red>" & CurrentPage & "</font>/" & n & "</strong>"&str(6)
	strTemp=strTemp & "&nbsp;<b>"&MaxPerPage&"</b>"&strUnit&"/"&str(7)
	if ShowAllPages=True then
		strTemp=strTemp & "&nbsp;"&str(8)&"<select name='page' size='1' onchange=""javascript:window.location='" & strUrl & "page=" & "'+this.options[this.selectedIndex].value;"">"   
		for i = 1 to n   
			strTemp=strTemp & "<option value='" & i & "'"
			if cint(CurrentPage)=cint(i) then strTemp=strTemp & " selected "
			strTemp=strTemp & ">"&i&"</option>"   
		next
		strTemp=strTemp & "</select>"
	end if
	strTemp=strTemp & "</td></tr></table>"
	response.write strTemp
end sub
function JoinChar(strUrl)
	if strUrl="" then
		JoinChar=""
		exit function
	end if
	if InStr(strUrl,"?")<len(strUrl) then 
		if InStr(strUrl,"?")>0 then
			if InStr(strUrl,"&")<len(strUrl) then 
				JoinChar=strUrl & "&"
			else
				JoinChar=strUrl
			end if
		else
			JoinChar=strUrl & "?"
		end if
	else
		JoinChar=strUrl
	end if
end function


Sub header()
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="Keywords" content="CMP,Flash,MP3,FLV,H264,Video,Music,Player,Blog,Zone,BBS,CenFun" />
<meta name="Description" content="CenFun Music Player v3.0 - bbs.cenfun.com" />
<meta name="copyright" content="2006-2008 Cenfun.Com" />
<title><%=site_name%></title>
<link rel="stylesheet" type="text/css" href="images/main.css" />
<script type="text/javascript" src="images/main.js"></script>
</head>
<body>
<%
end sub

sub menu()


%>
<div id="menu">
  <%If Session(CookieName & "_admin")<>"" then%>
  <a href="system.asp?action=config">系统配置</a> |
  <a href="system.asp?action=user">用户管理</a> |
  <%end if%>
  <%If Session(CookieName & "_username")<>"" then%>
  <a href="manage.asp?action=config">配置编辑</a> | <a href="manage.asp?action=list">列表编辑</a> | <a href="manage.asp?action=userinfo">个人资料</a> | <a href="index.asp?action=logout">退出</a>
  <%else%>
  <a href="index.asp?action=reg">注册</a> | <a href="index.asp">登录</a>
  <%end if%>
</div>
<%
end sub


Sub Cenfun_suc(url)
%>
<br />
<table cellpadding="3" cellspacing="1" align="center" class="tableBorder" style="width:75%">
  <tr align="center">
    <th height="25">成功信息</th>
  </tr>
  <tr>
    <td class="cmsRow"><%=SucMsg%></td>
  </tr>
  <tr>
    <td class="cmsRow"><%if url<>"" then%>
      <meta http-equiv="Refresh" content="3;URL=<%=url%>" />
      <li><b><span id="timeout">3</span>秒钟后自动返回...</b>
        <script type="text/javascript">
	function countDown(secs){
		document.getElementById('timeout').innerHTML=secs;
		if(--secs>0){
			setTimeout("countDown("+secs+")",1000);
		}
	}
	countDown(3);
    </script>
        <%end if%>
      </li></td>
  </tr>
  <tr>
    <td colspan="2" align="center" class="cmsRow">&lt;&lt;<a href="<%=Request.ServerVariables("HTTP_REFERER")%>">返回上一页</a></td>
  </tr>
</table>
<%
End Sub

Sub Cenfun_error()
%>
<br />
<table cellpadding="3" cellspacing="1" align="center" class="tableBorder" style="width:75%">
  <tr align="center">
    <th height="25" colspan="2">错误信息</th>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2">&nbsp;&nbsp;<strong>您在后台操作的时候发生错误,下面是可能的错误信息</strong></td>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2" style="color:#0000ff"><%=ErrMsg%></td>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2"><li>请仔细阅读相关帮助文件，确保您有相应的操作权限，或者点击<a href="login.asp"><strong>重新登录</strong></a>!</li></td>
  </tr>
  <tr>
    <td class="cmsRow" valign="middle" colspan="2" align="center"><a href="javascript:history.go(-1)">&lt;&lt; 返回上一页</a></td>
  </tr>
</table>
<%
	footer()
	response.End()
End Sub

Sub footer()
%>
<div id="footer">Copyright &copy; <a href="<%=site_url%>" target="_blank"><%=site_name%></a>. All Rights Reserved.<span>
  <!--页底页面统计，请更换成您自己的： -->
  <script src="http://js.users.51.la/2050763.js" type="text/javascript"></script>
  </span></div>
<%
response.Write("</body></html>")
End Sub
%>
