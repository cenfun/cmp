<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
Response.Charset = "utf-8"
'检测用户是否登录
If not founduser Then
	Dim u,p
	u=Checkstr(Request.QueryString("u"))
	p=Checkstr(Request.QueryString("p"))
	if u<>"" and p<>"" then
		sql = "select id from cmp_user where username='"&u&"' and password='"&p&"'"
		set rs=conn.Execute(sql)
		if rs.eof and rs.bof then
			Response.Write("uploadError{|}用户验证失败，无上传权限")
			Response.End()
		end if
		rs.close
		set rs=nothing	
	else
		Response.Write("uploadError{|}无效用户验证信息")
		Response.End()
	end if
end if

Select Case Request.QueryString("action")
	Case "uploadlrc"
		uploadlrc()
	Case Else
		Response.Write("uploadError{|}错误的操作参数")
 End Select


sub uploadlrc()
	dim savepath,maxsize
	'歌词保存至lrc目录
	savepath = "lrc/"
	'最大歌词文件大小50K
	maxsize = 50000
	'0大小判断
	dim formsize,formdata
	formsize = Request.TotalBytes
	if formsize < 1 then
		Response.Write("uploadError{|}上传文件的大小为0")
		Response.End()
	end if
	'取得表单数据
	Dim formStream,tempStream
	Set formStream = Server.CreateObject("ADODB.Stream")
	Set tempStream = Server.CreateObject("ADODB.Stream")
	formStream.Type = 1
	formStream.Mode = 3
	formStream.Open
	formStream.Write Request.BinaryRead(formsize)
	formStream.Position = 0
	formdata = formStream.Read
	'Response.BinaryWrite(formdata)
	If Err Then 
		Err.Clear
		Response.Write("uploadError{|}创建ADODB.Stream出错")
		Response.End()
	end if
	'超出大小跳出
	if maxsize>0 then
		if formsize>maxsize then
			Response.Write("uploadError{|}文件大小("&formsize&")超过限制" & maxsize)
			Response.End()
		end if
	end if
	'二进制换行分隔符
	dim bncrlf
	bncrlf=chrB(13) & chrB(10)
	'表单项分割符
	Dim PosBeg, PosEnd, boundary, boundaryPos, boundaryEnd
	'开始位置
    PosBeg = 1
    PosEnd = InstrB(PosBeg,formdata,bncrlf)
	'取得项分隔符
    boundary = MidB(formdata,PosBeg,PosEnd-PosBeg)
	'项分隔符位置
	boundaryPos = InstrB(PosBeg,formdata,boundary)
	boundaryEnd = InstrB(formsize-LenB(boundary)-LenB("--"),formdata,boundary)
	Do until (boundaryPos = boundaryEnd)
		'取得项信息位置
		PosBeg = boundaryPos+LenB(boundary)
        PosEnd = InstrB(PosBeg,formdata,bncrlf & bncrlf)
		'读取项信息字符
		tempStream.Type = 1
		tempStream.Mode = 3
		tempStream.Open
		formStream.Position = PosBeg
		formStream.CopyTo tempStream,PosEnd-PosBeg
		tempStream.Position = 0
		tempStream.Type = 2
		tempStream.CharSet = "utf-8"
		dim fileinfo
		fileinfo = tempStream.ReadText
		tempStream.Close
		'查找文件标识开始的位置
		dim fnBeg, fnEnd
		fnBeg = InStr(45,fileinfo,"filename=""",1)
		'如果是文件
		if fnBeg > 0 Then
            '取得文件名
			dim filename,fileurl
            fnBeg = fnBeg + 10
			fnEnd = InStr(fnBeg,fileinfo,""""&vbCrLf,1)
			filename = Trim(Mid(fileinfo,fnBeg,fnEnd-fnBeg))
			'过滤文件名中的路径
			filename = Mid(filename, InStrRev(filename,"\")+1)
			
			'扩展类型是否符合要求，仅保存txt类型
			dim ext
			ext = LCase(Right(filename, 4))
			if ext=".txt" then
				'生成文件
				fileurl = savepath & filename
				'取得文件数据位置
				PosBeg = InstrB(PosEnd,formdata,bncrlf & bncrlf)+4
				PosEnd = InstrB(PosBeg,formdata,boundary)-2
				'保存文件数据
				tempStream.Type = 1
				tempStream.Mode = 3
				tempStream.Open
				tempStream.Position = 0
				formStream.Position = PosBeg-1
				formStream.CopyTo tempStream,PosEnd-PosBeg
				tempStream.SaveToFile Server.Mappath(fileurl),2
				tempStream.Close
			
				'检查数据库记录
				sql = "select src from cmp_lrc where src='"&filename&"' "
				set rs = conn.execute(sql)
				if rs.eof and rs.bof then
					'保存新增路径到数据库
					conn.execute("insert into cmp_lrc (src) values('"&filename&"')")
					'完成歌词上传
					Response.Write("uploadComplete{|}" & fileurl)
				else
					Response.Write("uploadComplete{|}文件被覆盖" & fileurl)
				end if
				rs.close
				set rs = nothing
			else
				Response.Write("uploadError{|}仅支持*.txt类型的文件")
			end if
			Response.End()
			'找到文件项退出循环
			Exit Do
        else
			'非文件项，跳转到下一个项分隔符位置
        	BoundaryPos = InstrB(boundaryPos+LenB(boundary),formdata,boundary)
		End If
	Loop
	Set tempStream = nothing
	formStream.Close
	Set formStream = nothing
end sub
%>