<%
'用户登录状况
Dim founduser,foundadmin
if Session(CookieName & "_username")<>"" then
	founduser = true
	if Session(CookieName & "_admin")<>"" then
		foundadmin = true
	else
		foundadmin = false
	end if
else
	founduser = false
	foundadmin = false	
end if 

'站点关闭
if Application(CookieName&"_site_close")="1" and not foundadmin then
	Response.Charset = "utf-8"
	Response.Write("<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" />站点暂时关闭，请稍候访问！")	
	Response.End()
end if
'连接数据库
If Not IsObject(conn) Then ConnectionDatabase()
'系统缓存
Dim Arr_system_info
IF Not IsArray(Application(CookieName&"_Arr_system_info")) Then
	set rs=conn.Execute("select * from cmp_config")
	If rs.EOF And rs.BOF Then
		Redim Arr_system_info(12,0)
	Else
		Arr_system_info=rs.GetRows
	End If
	rs.Close
	Set rs=Nothing
	Application.Lock
	Application(CookieName&"_Arr_system_info")=Arr_system_info
	Application.UnLock
else
	Arr_system_info=Application(CookieName&"_Arr_system_info")
End IF
Dim cmp_path,site_title,site_name,site_url,site_qq,site_email,site_count,site_ads,user_reg,user_check,xml_make,xml_path,xml_config,xml_list
cmp_path = Arr_system_info(0,0)
if cmp_path="" then cmp_path="cmp.swf"
site_name = Arr_system_info(1,0)
site_url = Arr_system_info(2,0)
site_qq = Arr_system_info(3,0)
site_email = Arr_system_info(4,0)
site_count = Arr_system_info(5,0)
site_ads = Arr_system_info(6,0)
user_reg = Arr_system_info(7,0)
user_check = Arr_system_info(8,0)
xml_make = Arr_system_info(9,0)
xml_path = Arr_system_info(10,0)
if xml_path="" then xml_path="xml"
xml_config = Arr_system_info(11,0)
if xml_config="" then xml_config="c.xml"
xml_list = Arr_system_info(12,0)
if xml_list="" then xml_list="l.xml"
'解析公告和广告
dim site_ad_news,site_ad_top,site_ad_bottom
site_ads=Split(UnCheckstr(site_ads),"{|}")
site_ad_news=site_ads(0)
if Ubound(site_ads)=2 then
	site_ad_top=site_ads(1)
	site_ad_bottom=site_ads(2)
end if
'取得真实IP
dim UserTrueIP
UserTrueIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR")
If UserTrueIP = "" Then UserTrueIP = Request.ServerVariables("REMOTE_ADDR")

'查询IP地址
function getIpUrl(ip)
	getIpUrl = "http://www.baidu.com/s?wd=" & ip
end function

'调用QQ地址
function getQqUrl(qq)
	getQqUrl = "http://wpa.qq.com/msgrd?Uin=" & qq
end function

function getCmpPath()
	dim cmp
	'http://
	if Left(LCase(cmp_path),7)="http://" then
		cmp = cmp_path
	elseif Left(cmp_path,1)="/" then
		cmp = "http://"&Request.ServerVariables("HTTP_HOST") & cmp_path
	else
		dim this_path
		this_path="http://"&Request.ServerVariables("HTTP_HOST")&left(Request.ServerVariables("PATH_INFO"),InStrRev(Request.ServerVariables("PATH_INFO"),"/"))
		cmp = this_path & cmp_path
	end if
	getCmpPath = cmp
end function

'CMP调用地址
function getCmpUrl(id)
	dim cmp
	cmp = getCmpPath()
	cmp = cmp & "?url=" & geturl(id)
	'添加flash后缀
	cmp = cmp & "&c.swf"
	getCmpUrl = cmp
end function

'CMP页面地址
function getCmpPageUrl(id)
	dim this_path
	this_path="http://"&Request.ServerVariables("HTTP_HOST")&left(Request.ServerVariables("PATH_INFO"),InStrRev(Request.ServerVariables("PATH_INFO"),"/"))
	getCmpPageUrl = this_path & "cmp.asp?id=" & id
end function

'取得动静态地址
function geturl(id)
	dim url
	if xml_make = "1" then
		url = xml_path & "/" & id & xml_config
	else
		'config.asp%3Fid%3D1 
		'config.asp?  id=  1 
		url = "config.asp%3Fid%3D" & id
	end if
	geturl = url
end function

'正则替换配置文件列表地址，名称，网站
function setLNU(strContent, xml_make, xml_path, xml_list, id, cmp_name, cmp_url)
	If IsNull(strContent) Then
		setLNU = ""
		Exit Function 
	End If
	'替换列表地址
	dim re
	Set re=new RegExp
	re.IgnoreCase =True
	re.Global=True
	re.Pattern="(<cmp[^>]+list *= *\"")[^\r]*?(\""[^>]*>)"
	if xml_make="1" then
		strContent=re.Replace(strContent,"$1" & xml_path & "/" & id & xml_list & "$2")
	else
		strContent=re.Replace(strContent,"$1list.asp?id="&id&"$2")
	end if
	'名称，网址替换
	re.Pattern="(<cmp[^>]+name *= *\"")[^\r]*?(\""[^>]*>)"
	strContent=re.Replace(strContent,"$1" & cmp_name & "$2")
	re.Pattern="(<cmp[^>]+url *= *\"")[^\r]*?(\""[^>]*>)"
	strContent=re.Replace(strContent,"$1" & cmp_url & "$2")
	Set re=nothing
	setLNU = strContent
end function

'验证码简单混淆
function getCode(code)
	dim str,i,rd,num
	for i = 0 to 3
		rd = cint(rnd*9)
		num = Mid(code, i + 1, 1)
		if num > 5 then
			str = str & "<span style=""display:none;"">" & num & "</span>"
		end if
		if rd > 5 then
			str = str & "<span style=""color:#000000;"">" & rd & "</span>"
			str = str & "<span style=""color:#ffffff;"">" & num & "</span>"
		else
			str = str & "<span style=""color:#ffffff;"">" & num & "</span>"
			str = str & "<span style=""color:#000000;"">" & rd & "</span>"
		end if
		if num < 5 then
			str = str & "<span style=""display:none;"">" & rd & "</span>"
		end if
	next
	getCode = str
end function

'添加utf-8编码的XML文件头
function addUTFBOM()
	Response.BinaryWrite(ChrB(239))
	Response.BinaryWrite(ChrB(187))
	Response.BinaryWrite(ChrB(191))
	Response.Charset = "utf-8"
	Response.AddHeader "Content-Type", "text/xml"
end function
'*************************************
'检测系统组件是否安装
'*************************************
Function CheckObjInstalled(strClassString)
	On Error Resume Next
	Dim Temp
	Err = 0
	Dim TmpObj
	Set TmpObj = Server.CreateObject(strClassString)
	Temp = Err
	IF Temp = 0 OR Temp = -2147221477 Then
		CheckObjInstalled=true
	ElseIF Temp = 1 OR Temp = -2147221005 Then
		CheckObjInstalled=false
	End IF
	Err.Clear
	Set TmpObj = Nothing
	Err = 0
End Function
'*************************************
'过滤特殊字符
'*************************************
Function CheckStr(byVal ChkStr) 
	Dim Str:Str=ChkStr
	If IsNull(Str) Then
		CheckStr = ""
		Exit Function 
	End If
    Str = Replace(Str, "&", "&amp;")
    Str = Replace(Str,"'","&#39;")
    Str = Replace(Str,"""","&#34;")
	Dim re
	Set re=new RegExp
	re.IgnoreCase =True
	re.Global=True
	re.Pattern="(w)(here)"
    Str = re.replace(Str,"$1h&#101;re")
	re.Pattern="(s)(elect)"
    Str = re.replace(Str,"$1el&#101;ct")
	re.Pattern="(i)(nsert)"
    Str = re.replace(Str,"$1ns&#101;rt")
	re.Pattern="(c)(reate)"
    Str = re.replace(Str,"$1r&#101;ate")
	re.Pattern="(d)(rop)"
    Str = re.replace(Str,"$1ro&#112;")
	re.Pattern="(a)(lter)"
    Str = re.replace(Str,"$1lt&#101;r")
	re.Pattern="(d)(elete)"
    Str = re.replace(Str,"$1el&#101;te")
	re.Pattern="(u)(pdate)"
    Str = re.replace(Str,"$1p&#100;ate")
	re.Pattern="(\s)(or)"
    Str = re.replace(Str,"$1o&#114;")
	Set re=Nothing
	CheckStr=Str
End Function
'*************************************
'恢复特殊字符
'*************************************
Function UnCheckStr(ByVal Str)
		If IsNull(Str) Then
			UnCheckStr = ""
			Exit Function 
		End If
	    Str = Replace(Str,"&#39;","'")
        Str = Replace(Str,"&#34;","""")
		Dim re
		Set re=new RegExp
		re.IgnoreCase =True
		re.Global=True
		re.Pattern="(w)(h&#101;re)"
	    str = re.replace(str,"$1here")
		re.Pattern="(s)(el&#101;ct)"
	    str = re.replace(str,"$1elect")
		re.Pattern="(i)(ns&#101;rt)"
	    str = re.replace(str,"$1nsert")
		re.Pattern="(c)(r&#101;ate)"
	    str = re.replace(str,"$1reate")
		re.Pattern="(d)(ro&#112;)"
	    str = re.replace(str,"$1rop")
		re.Pattern="(a)(lt&#101;r)"
	    str = re.replace(str,"$1lter")
		re.Pattern="(d)(el&#101;te)"
	    str = re.replace(str,"$1elete")
		re.Pattern="(u)(p&#100;ate)"
	    str = re.replace(str,"$1pdate")
		re.Pattern="(\s)(o&#114;)"
	    Str = re.replace(Str,"$1or")
		Set re=Nothing
        Str = Replace(Str, "&amp;", "&")
    	UnCheckStr=Str
End Function
'*************************************
'过滤XML属性的特殊字符串
'*************************************
Function XMLEncode(ByVal reString) 
	Dim Str:Str=reString
	If Not IsNull(Str) Then
		Str = UnCheckStr(Str)
		Str = Replace(Str, "&", "&amp;")
   		Str = Replace(Str, ">", "&gt;")
		Str = Replace(Str, "<", "&lt;")
    	Str = Replace(Str, CHR(34), "&quot;")
		XMLEncode = Str
	End If
End Function
'*************************************
'转换HTML代码
'*************************************
Function HTMLEncode(ByVal reString) 
	Dim Str:Str=reString
	If Not IsNull(Str) Then
   		Str = Replace(Str, ">", "&gt;")
		Str = Replace(Str, "<", "&lt;")
	    Str = Replace(Str, CHR(9), "&#160;&#160;&#160;&#160;")
	    Str = Replace(Str, CHR(32), "&nbsp;")
	    Str = Replace(Str, CHR(39), "&#39;")
    	Str = Replace(Str, CHR(34), "&quot;")
		Str = Replace(Str, CHR(13), "")
		Str = Replace(Str, CHR(10), "<br/>")
		HTMLEncode = Str
	End If
End Function
'*************************************
'反转换HTML代码
'*************************************
Function HTMLDecode(ByVal reString) 
	Dim Str:Str=reString
	If Not IsNull(Str) Then
		Str = Replace(Str, "&gt;", ">")
		Str = Replace(Str, "&lt;", "<")
		Str = Replace(Str, "&#160;&#160;&#160;&#160;", CHR(9))
	    Str = Replace(Str, "&nbsp;", CHR(32))
		Str = Replace(Str, "&#39;", CHR(39))
		Str = Replace(Str, "&quot;", CHR(34))
		Str = Replace(Str, "", CHR(13))
		Str = Replace(Str, "<br/>", CHR(10))
		HTMLDecode = Str
	End If
End Function
'*************************************
'过滤HTML代码
'*************************************
Function EditDeHTML(byVal Content)
	EditDeHTML=Content
	IF Not IsNull(EditDeHTML) Then
		EditDeHTML=UnCheckStr(EditDeHTML)
		EditDeHTML=Replace(EditDeHTML,"&","&amp;")
		EditDeHTML=Replace(EditDeHTML,"<","&lt;")
		EditDeHTML=Replace(EditDeHTML,">","&gt;")
		EditDeHTML=Replace(EditDeHTML,chr(34),"&quot;")
		EditDeHTML=Replace(EditDeHTML,chr(39),"&#39;")
	End IF
End Function
'获取文件信息
function getFileInfo(FileName)
	dim FSO,File,FileInfo(3)
	if CheckObjInstalled("Scripting.FileSystemObject")=true then
		Set FSO=Server.CreateObject("Scripting.FileSystemObject")
		if FSO.FileExists(Server.MapPath(FileName)) then
			Set File=FSO.GetFile(Server.MapPath(FileName))
			FileInfo(0)=File.Size
			if FileInfo(0)/1000>1 then 
				FileInfo(0)=int(FileInfo(0)/1000)&" KB"
			else
				FileInfo(0)=FileInfo(0)&" Bytes"
			end if
			FileInfo(1)=lcase(right(FileName,4))
			FileInfo(2)=File.DateCreated
			FileInfo(3)=File.Type 
			Set File=nothing
		end if
		Set FSO=Nothing
	end if
	getFileInfo=FileInfo
end function

'获取文件夹大小
function getFolderSize(path)
	dim FSO,folder,FolderSize,str
	if CheckObjInstalled("Scripting.FileSystemObject")=true then
		Set FSO=Server.CreateObject("Scripting.FileSystemObject")
		if FSO.FolderExists(Server.MapPath(path)) then	 		
			set folder=FSO.getfolder(Server.MapPath(path)) 		
			FolderSize=folder.size
			str=FolderSize & " Bytes" 
			if FolderSize>1024 then
			   FolderSize=(FolderSize/1024)
			   str=formatnumber(FolderSize,2) & " KB"
			end if
			if FolderSize>1024 then
			   FolderSize=(FolderSize/1024)
			   str=formatnumber(FolderSize,2) & "MB"		
			end if
			if FolderSize>1024 then
			   FolderSize=(FolderSize/1024)
			   str=formatnumber(FolderSize,2) & "GB"	   
			end if  
			set folder=nothing 
		end if
		Set FSO=Nothing
	end if
	getFolderSize = str
End function

'分页显示
function showpage(language,format,sfilename,totalnumber,MaxPerPage,ShowTotal,ShowAllPages,strUnit,CurrentPage)
	dim zh,en,str
	zh="共,【首页】,【上一页】,【下一页】,【尾页】,页次：,页,页,转到："
	en="Total,First,Previous,Next,Last,Page:,&nbsp;,Page,Go:"
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
	strTemp="<span>"
	if ShowTotal=true then 
		strTemp=strTemp & "<span style='padding-right:10px;'>" & str(0) & "<strong>" & totalnumber & "</strong>" & strUnit & "</span>"
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
	strTemp=strTemp & "<span style='padding:0px 10px;'>"&str(5)&"<strong><font color='#ff0000'>" & CurrentPage & "</font>/" & n & "</strong>"&str(6)&"</span>"
	strTemp=strTemp & "<strong>"&MaxPerPage&"</strong>"&strUnit&"/"&str(7)
	if ShowAllPages=True and n < 1000 then
		strTemp=strTemp &"<span style='padding-left:10px;'>"&str(8)
		strTemp=strTemp &"<select name='page' size='1' onchange=""javascript:window.location='" & strUrl & "page=" & "'+this.options[this.selectedIndex].value;"">"
		for i = 1 to n   
			strTemp=strTemp & "<option value='" & i & "'"
			if cint(CurrentPage)=cint(i) then strTemp=strTemp & " selected "
			strTemp=strTemp & ">"&i&"</option>"   
		next
		strTemp=strTemp & "</select>"
		strTemp=strTemp & "</span>"
	end if
	strTemp=strTemp & "</span>"
	showpage = strTemp
end function
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

'生成文件
function makeFile(byVal path, byVal text)
	On Error Resume Next
	dim objStream
	Set objStream = Server.CreateObject("ADODB.Stream")
	If Err Then 
		Err.Clear
		ErrMsg = "服务器不支持ADODB.Stream"
		cenfun_error()
	else
		With objStream
		.Open
		.Charset = "utf-8"
		.Position = objStream.Size
		.WriteText = text
		.SaveToFile Server.Mappath(path),2 
		.Close
		End With
		If Err Then 
			Err.Clear
			ErrMsg = "写入文件失败，请检查服务器是否有可写权限！"
			cenfun_error()
		end if
	end if
	Set objStream = Nothing
end function

'删除单个文件
function delFile(byVal path)
	On Error Resume Next
	dim FSO
	Set FSO=Server.CreateObject("Scripting.FileSystemObject")
		if FSO.FileExists(Server.MapPath(path)) then	
			FSO.DeleteFile (Server.MapPath(path))
		end if
		If Err Then 
			Err.Clear
			ErrMsg = "删除文件失败！请检查服务器是否有可写权限！"
			cenfun_error()
		end if
	Set FSO=Nothing	
end function

'创建目录
function makeFolder(byVal path)
	On Error Resume Next
	dim FSO
	Set FSO=Server.CreateObject("Scripting.FileSystemObject")
		if not FSO.FolderExists(Server.MapPath(path)) then
			FSO.CreateFolder(Server.MapPath(path))
		end if
		If Err Then
			Err.Clear
			ErrMsg = "创建文件夹失败，请检查服务器是否有可写权限！"
			cenfun_error()
		end if
	Set FSO=Nothing
end function

'删除目录
function delFolder(byVal path)
	if CheckObjInstalled("Scripting.FileSystemObject")=true then
		dim FSO
		Set FSO=Server.CreateObject("Scripting.FileSystemObject")
		if FSO.FolderExists(Server.MapPath(path)) then
			On Error Resume Next
			FSO.DeleteFolder (Server.MapPath(path))
			If Err Then 
				Err.Clear
				ErrMsg = "删除文件夹失败，请检查服务器是否有可写权限！"
				cenfun_error()
			end if
		end if
		Set FSO=Nothing
	end if
end function

'公共头
Sub header()
dim mytitle
if site_title<>"" then
	mytitle=site_name&" - "&site_title
else
	mytitle=site_name
end if
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="Keywords" content="CMP,Manage,Flash,MP3,FLV,H264,Video,Music,Player,Blog,Zone,BBS,CenFun" />
<meta name="Description" content="CenFun Music Player v3.0 - bbs.cenfun.com" />
<meta name="Copyright" content="2006-2008 Cenfun.Com" />
<title><%=mytitle%></title>
<link rel="stylesheet" type="text/css" href="<%=dbpath%>images/main.css" />
<script type="text/javascript" src="<%=dbpath%>images/main.js"></script>
</head>
<body>
<%
end sub

sub menu()
%>
<div id="menu">
  <ul class="nav" id="mymenu">
    <%If Session(CookieName & "_username")<>"" then%>
    <li class="right"><a href="index.asp?action=logout">退出</a></li>
    <%If Session(CookieName & "_admin")<>"" then%>
    <li class="right"><a href="system.asp">系统管理</a>
      <ul>
        <li><a href="system.asp?action=config" title="System">系统设置</a></li>
        <li><a href="system.asp?action=user" title="Users">用户管理</a></li>
        <li><a href="system.asp?action=skins" title="Skins">皮肤管理</a></li>
        <li><a href="system.asp?action=plugins" title="Plugins">插件管理</a></li>
		<li><a href="system.asp?action=lrc" title="LRC">歌词管理</a></li>
      </ul>
    </li>
    <%end if%>
    <li class="right"><a href="manage.asp?action=userinfo">个人资料</a></li>
    <li class="right"><span>欢迎：<%=Session(CookieName & "_username")%></span></li>
    <li><a href="manage.asp">调用代码</a></li>
    <li><a href="manage.asp?action=config" title="Config">配置编辑</a>
      <ul>
        <li><a href="manage.asp?action=config">普通编辑模式</a></li>
        <li><a href="manage.asp?action=config&mode=code">代码编辑模式</a></li>
      </ul>
    </li>
    <li><a href="manage.asp?action=list" title="List">列表编辑</a>
      <ul>
        <li><a href="manage.asp?action=list">普通编辑模式</a></li>
        <li><a href="manage.asp?action=list&mode=code">代码编辑模式</a></li>
      </ul>
    </li>
    <%else%>
    <li><a href="index.asp">登录</a></li>
    <li><a href="index.asp?action=reg">免费注册</a></li>
    <li class="right"><a href="index.asp"><%=site_name%></a></li>
    <%end if%>
    <!--#include file="menu.asp"-->
  </ul>
</div>
<script type="text/javascript">
function initmenu(o) {
	var menu = document.getElementById(o);
	var as = menu.getElementsByTagName("a");
	for (var i = 0; i < as.length; i ++) {
		var ta = as[i];
		var tn = ta.nextSibling;
		checkDropList(ta, tn);
	}
}
function checkDropList(ta, tn) {
	if (tn) {
		if (tn.nodeType == 1) {
			addMenuEvent(ta, tn);
		} else {
			checkDropList(ta, tn.nextSibling);
		}
	}
}
function addMenuEvent(ta, tn) {
	ta.className = "drop";
	var tp = ta.parentNode;
	if (tp) {
		tp.onmouseover = function(e) {tn.style.display = "block";}
		tp.onmouseout = function(e) {tn.style.display = "none";}
	}
}
initmenu("mymenu");
</script>
<%
if site_ad_top<>"" then
	Response.Write("<div class=""ads"">"&site_ad_top&"</div>")
end if
end sub


Sub cenfun_suc(url)
%>
<br />
<script type="text/javascript">
function countDown(secs){
	document.getElementById("timeout").innerHTML=secs;
	secs --;
	if(secs>=0){
		setTimeout("countDown("+secs+")",1000);
	} else {
		window.location = "<%=url%>";
	}
}
</script>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="75%">
  <tr>
    <th>成功信息</th>
  </tr>
  <tr>
    <td align="center"><%=SucMsg%>
      <%if url<>"" then%>
      <span id="timeout">3</span>秒钟后自动返回
      <script type="text/javascript">countDown(3);</script>
      <%end if%>
    </td>
  </tr>
  <tr>
    <td align="center"><a href="<%=url%>">如果您的浏览器没有自动跳转，请点击这里</a></td>
  </tr>
</table>
<%
End Sub

Sub cenfun_error()
%>
<br />
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="75%">
  <tr>
    <th>您在操作时发生错误</th>
  </tr>
  <tr>
    <td align="center"><span style="color:#FF0000;"><%=ErrMsg%></span></td>
  </tr>
  <tr>
    <td align="center"><a href="javascript:history.back();">&lt;&lt; 返回上一页</a></td>
  </tr>
</table>
<%
	footer()
	response.End()
End Sub

Sub footer()
if site_ad_bottom<>"" then
	Response.Write("<div class=""ads"">"&site_ad_bottom&"</div>")
end if
%>
<div id="footer">Copyright &copy; <a href="<%=site_url%>" target="_blank"><%=site_name%></a> <a href="http://bbs.cenfun.com/" target="_blank"><%=siteVersion%></a>. All Rights Reserved. Powered by <a href="mailto:cenfun@gmail.com" target="_blank">CenFun</a><span><img src="<%=site_count%>" /></span></div>
<%
response.Write("</body></html>")
'关闭所有连接
If conn.state <> 0 Then 
	conn.close
	set conn = nothing
end if
End Sub
%>
