<%@ LANGUAGE = "VBScript" CodePage = "65001"%>
<%
Option Explicit
Response.Buffer = True
Server.ScriptTimeOut = 90
Session.CodePage = 65001
Session.LCID = 2057

Dim sitename,siteurl,siteemail,sitedb
'站点名称
sitename = "CMP在线管理系统"
'站点网站
siteurl = "http://bbs.cenfun.com/"
'管理员邮箱
siteemail = "cenfun@gmail.com"
'站点数据库路径
sitedb = "data/#cmp3_2008.mdb"


'/////////////////////////////////////////
Dim Startime,SqlNowString,SystemTime
Dim conn,rs,sql,FoundErr,ErrMsg,SucMsg
FoundErr=False 
Startime = Timer()
SqlNowString = "Now()"
SystemTime=Now()
'站点cookies唯一标识
Const CookieName="cenfun_cmp3"
'数据连接
Sub ConnectionDatabase
	Dim ConnStr
		ConnStr = "Provider = Microsoft.Jet.OLEDB.4.0;Data Source = " & Server.MapPath(sitedb)
	On Error Resume Next
	Set conn = Server.CreateObject("ADODB.Connection")
	conn.open ConnStr
	If Err Then
		err.Clear
		Set Conn = Nothing
		Response.Write "数据库连接出错，请检查连接字串。"
		Response.End
	End If
End Sub
If Not IsObject(conn) Then ConnectionDatabase
%>