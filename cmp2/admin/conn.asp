<%@ LANGUAGE = VBScript CodePage = 936%>
<%
Option Explicit
Response.Buffer = True
Server.ScriptTimeOut = 90
Session.CodePage=936
Session.LCID=2057

Dim Startime
Dim SqlNowString,SystemTime,Cenfun,template,UserOnline
Dim Conn,Plus_Conn,Db,MyDbPath
Dim FoundErr
FoundErr=False 
Dim ErrMsg,SucMsg
Dim Rs,sql,i,jc,jcs
Startime = Timer()
'数据库路径
MyDbPath = ""
Db = "data/#cfplay_data_2006.mdb"
SqlNowString = "Now()"
SystemTime=Now()
'站点cookies唯一标识
Const CookieName="cenfun_cfplay"
'数据连接
Sub ConnectionDatabase
	Dim ConnStr
		ConnStr = "Provider = Microsoft.Jet.OLEDB.4.0;Data Source = " & Server.MapPath(MyDbPath & db)
	On Error Resume Next
	Set conn = Server.CreateObject("ADODB.Connection")
	conn.open ConnStr
	If Err Then
		err.Clear
		Set Conn = Nothing
		Response.Write "数据库连接出错，请检查连接字串。"'注释，需要把这几个字翻译成英文。
		Response.End
	End If
End Sub
If Not IsObject(Conn) Then ConnectionDatabase
'head
%>