<%@ LANGUAGE = "VBScript" CodePage = "65001"%>
<%
Option Explicit
Response.Buffer = True
Server.ScriptTimeOut = 90
Session.CodePage = 65001
Session.LCID = 2057

'站点数据库路径
Dim sitedb
	sitedb = "data/#cmp3_2008.mdb"
Dim Startime,SqlNowString,SystemTime
Dim conn,rs,sql,FoundErr,ErrMsg,SucMsg
FoundErr=False 
Startime = Timer()
SqlNowString = "Now()"
SystemTime=Now()
'站点cookies唯一标识
Const CookieName="cenfun_cmp3"
'数据连接
'on error resume next
Set conn= Server.CreateObject("ADODB.Connection")
conn.ConnectionString="Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.MapPath(sitedb)
conn.Open
If Err Then
	err.Clear
	Set Conn = Nothing
	Response.Write("<meta http-equiv=""Content-Type"" content=""text/html; charset=UTF-8"" />数据库连接出错，请检查连接字串")
	Response.End
end if
%>