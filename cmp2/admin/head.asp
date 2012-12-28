<%
dim UserTrueIP
UserTrueIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
	If UserTrueIP = "" Then UserTrueIP = Request.ServerVariables("REMOTE_ADDR")

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
    <td class="cmsRow" colspan="2">&nbsp;&nbsp;<strong>您在后台操作的时候发生错误,下面是可能的错误信息</strong> </td>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2" style="color:#0000ff"><%=ErrMsg%></td>
  </tr>
  <tr>
    <td class="cmsRow" colspan="2"><li>请仔细阅读相关帮助文件，确保您有相应的操作权限，或者点击<a href="login.asp"><strong>重新登录</strong></a>! </li></td>
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
<table width="75%" border="0" align="center" cellpadding="2" cellspacing="1" >
  <tr align="center">
    <td class="copyright"><a href="http://www.cenfun.com/cfplay/" target="_blank" class="copyright">CenFun Music Player</a>, Copyright (c) 2005-2006 <a href="http://www.cenfun.com/" target="_blank"><font color="#708796"><b>CenFun</b></font></a>. All Rights Reserved . </td>
  </tr>
</table>
</body>
</html>
<%
End Sub
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=gb2312">
<meta name=keywords content="晨风,Cenfun">
<meta name="description" content="Design By www.Cenfun.com">
<title>CenFun Music Player Manage</title>
<style type="text/css">
body {
	background:#CAD7F7; font-size: 12px; margin-top:0px;
	SCROLLBAR-FACE-COLOR: #799AE1; SCROLLBAR-HIGHLIGHT-COLOR: #799AE1; 
	SCROLLBAR-SHADOW-COLOR: #799AE1; SCROLLBAR-DARKSHADOW-COLOR: #799AE1; 
	SCROLLBAR-3DLIGHT-COLOR: #799AE1; SCROLLBAR-ARROW-COLOR: #FFFFFF;
	SCROLLBAR-TRACK-COLOR: #AABFEC;
}
td,span,div,input,textarea{
	font-size:12px;
}
input,textarea{
	border:solid 1px #999999;
}
A {
	COLOR: #000000; TEXT-DECORATION: none;
}
A:hover { color:#428EFF;text-decoration:underline; }
A.highlight {
	COLOR: red; TEXT-DECORATION: none;
}
A.highlight:hover {
	COLOR: red;
}
A.thisclass {
	FONT-WEIGHT: bold; TEXT-DECORATION: none
}
A.thisclass:hover {
	FONT-WEIGHT: bold;
}
A.navlink {
	COLOR: #000000; TEXT-DECORATION: none;
}
A.navlink:hover {
	COLOR: #003399; TEXT-DECORATION: none;
}
.content {
	FONT-SIZE: 14px; MARGIN: 5px 20px; LINE-HEIGHT: 140%; FONT-FAMILY: Tahoma,宋体
}
#TableTitleLink{
	font-weight:bold;
	COLOR: #ffffff; 
}
#TableTitleLink A:link,#TableTitleLink A:visited,#TableTitleLink A:active{
	COLOR: #ffffff; TEXT-DECORATION: none
}
#TableTitleLink A:hover {
	COLOR: #ffffff; TEXT-DECORATION: underline
}
.cmsRow {
	PADDING-RIGHT: 3px; PADDING-LEFT: 3px; BACKGROUND: #F1F3F5; PADDING-BOTTOM: 3px; PADDING-TOP: 3px
}
.cmsRow01 {
	PADDING-RIGHT: 3px; PADDING-LEFT: 3px; BACKGROUND: #F1F1F1; PADDING-BOTTOM: 3px; PADDING-TOP: 3px
}
.cmsRow02 {
	PADDING-RIGHT: 3px; PADDING-LEFT: 3px; BACKGROUND: #FFFFFF; PADDING-BOTTOM: 3px; PADDING-TOP: 3px
}
TH {
	FONT-WEIGHT: bold; FONT-SIZE: 12px; BACKGROUND-IMAGE: url(images/admin_bg_1.gif); COLOR: white; BACKGROUND-COLOR: #4455aa
}
.tableBorder {
	BORDER-RIGHT: #183789 1px solid; BORDER-TOP: #183789 1px solid; BORDER-LEFT: #183789 1px solid; WIDTH: 98%; BORDER-BOTTOM: #183789 1px solid; BACKGROUND-COLOR: #ffffff
}
.tableBorder1 {WIDTH: 98%; }
.copyright {
	PADDING-RIGHT: 1px; BORDER-TOP: #6595d6 1px dashed; PADDING-LEFT: 1px; PADDING-BOTTOM: 1px; FONT: 12px verdana,arial,helvetica,sans-serif; COLOR: #4455aa; PADDING-TOP: 1px; TEXT-DECORATION: none
}
</style>
<script language="JavaScript" type="text/javascript">
function unselectall()
{
    if(document.myform.chkAll.checked){
	document.myform.chkAll.checked = document.myform.chkAll.checked&0;
    } 	
}
function CheckAll(form)
  {
  for (var i=0;i<form.elements.length;i++)
    {
    var e = form.elements[i];
    if (e.Name != "chkAll"&&e.disabled==false)
       e.checked = form.chkAll.checked;
    }
  }
function CheckForm()
{
  if (document.myform.ID.value=="")
  {
    alert("文章所属栏目不能指定为含有子栏目的栏目！");
	document.myform.ID.focus();
	return false;
  }
  return true;  
}

function test()
{
  if(!confirm('确认删除吗？')) return false;
}
</script>
</head>
<body leftmargin="0" topmargin="0" marginheight="0" marginwidth="0">
<%
If Session(CookieName & "_flag")<>"" then
	if request("nomenu")<>"1" then
%>
<table width="98%" border="0" align="center" cellpadding="0" cellspacing="0" id="TableTitleLink">
  <tr>
    <td background="images/top_bg.gif">&nbsp;■ <a href="manage.asp">播放器管理</a> | <a href="user.asp">管理密码修改</a> | <a href="login.asp?action=out">退出</a></td>
    <td align="right" background="images/top_bg.gif"><a href="http://www.cenfun.com/cfplay/" target="_blank"><img src="images/top_logo.gif" width="46" height="32" border="0" /></a></td>
  </tr>
</table>
<%
	end if
end if
%>
