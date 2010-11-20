<%@ LANGUAGE = "VBScript" CodePage = "65001"%>
<%
Option Explicit
Response.Buffer = True
Server.ScriptTimeOut = 90
Session.CodePage = 65001
Session.LCID = 2057

'站点数据库路径
Dim sitedb,dbpath
	sitedb = "data/#cmponline_for_cmp4.mdb"
	dbpath = ""
Dim Startime,SqlNowString,SystemTime
Dim conn,rs,sql,FoundErr,ErrMsg,SucMsg
FoundErr=False 
Startime = Timer()
SqlNowString = "Now()"
SystemTime=Now()
'站点cookies唯一标识
Const CookieName="cmponline"
'数据连接
Sub ConnectionDatabase()
	'on error resume next
	Set conn= Server.CreateObject("ADODB.Connection")
	conn.ConnectionString="Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.MapPath(dbpath & sitedb)
	conn.Open
	If Err Then
		err.Clear
		Set Conn = Nothing
		Response.Charset = "utf-8"
		Response.Write("<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" />can not connect to database")
		Response.End()
	end If
End Sub
%>