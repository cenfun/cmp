<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
passport()
'//////////////////////////////
Select Case Request("action")
Case "manage"
	Call guide()
	Call manage()
	Call Footer()
Case "save_manage"
	Call guide()
	Call save_manage()	
	Call Footer()
Case "class_manage"
	Call guide()
	Call class_manage()
	Call Footer()
Case "save_class_manage"
	Call guide()
	Call save_class_manage()
	Call Footer()
Case "config"
	Call guide()
	Call config()
	Call Footer()
Case "save_config"
	Call guide()
	Call save_config()
	Call Footer()
Case "make_xml"
	Call guide()
	Call make_xml()
	Call Footer()
Case "show"
	Call guide()
	Call show()
	Call Footer()
Case "check_music_name"
	Call check_music_name()
Case "make_lrc"
	Call make_lrc()
	Call Footer()
Case Else
	Call guide()
	Call main()
	Call Footer()
End Select
If Errmsg<>"" Then cenfun_error()

sub guide()

end sub

sub main()
%>

<%
end sub

sub manage()

end sub

Sub save_manage()
dim saveaction,sql
dim id,classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,hits,addtime,lasttime,isbest,sn
dim addtime_sql,lasttime_sql
	saveaction=request.QueryString("save_manage")
	classid=Request("classid")
		if classid="" then Errmsg=Errmsg&"<li>专辑不能为空!请返回重新填写信息!"
	title=Replace(trim(Request("title")),"'","")
		if title="" then Errmsg=Errmsg&"<li>名称不能为空!请返回重新填写信息!"
	url=Replace(trim(Request("url")),"'","")
		if url="" then Errmsg=Errmsg&"<li>地址不能为空!请返回重新填写信息!"
	lrc=Replace(trim(Request("lrc")),"'","")
	content=Replace(trim(Request("content")),"'","")
	pic=Replace(trim(Request("pic")),"'","")
	x=Replace(trim(Request("x")),"'","")
	y=Replace(trim(Request("y")),"'","")
	w=Replace(trim(Request("w")),"'","")
	h=Replace(trim(Request("h")),"'","")
	s=Replace(trim(Request("s")),"'","")
	a=Replace(trim(Request("a")),"'","")
	c=Replace(trim(Request("c")),"'","")
	u=Replace(trim(Request("u")),"'","")
	scene=Replace(trim(Request("scene")),"'","")
	hits=Replace(trim(Request("hits")),"'","")
	addtime=Request("addtime")
		if IsDate(addtime) then
			addtime_sql="addtime='"&addtime&"',"
		end if
	lasttime=Request("lasttime")
		if IsDate(lasttime) then
			lasttime_sql="lasttime='"&lasttime&"',"
		end if
	isbest=Request("isbest")
		if isbest<>1 then isbest=0
	sn=Replace(trim(Request("sn")),"'","")
		if sn="" then sn=0
if saveaction="edit" then
	saveaction=""
	id=Request("id")
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cfplay_list Set classid="&classid&",title='"&title&"',url='"&url&"',lrc='"&lrc&"',content='"&content&"',pic='"&pic&"',x='"&x&"',y='"&y&"',w='"&w&"',h='"&h&"',s='"&s&"',a='"&a&"',c='"&c&"',u='"&u&"',scene='"&scene&"',isbest="&isbest&","&addtime_sql&""&lasttime_sql&"sn="&sn&" Where id="&id&"")
		SucMsg=SucMsg&"<li>修改资料成功!"
		Cenfun_suc("?")
	end if
end if

if saveaction="add" then
	saveaction=""
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		'response.write "classid="&classid&"/url="&url&"/isbest="&isbest
		sql="insert into cfplay_list (classid,title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene,addtime,lasttime,isbest,sn) values("&classid&",'"&title&"','"&url&"','"&lrc&"','"&content&"','"&pic&"','"&x&"','"&y&"','"&w&"','"&h&"','"&s&"','"&a&"','"&c&"','"&u&"','"&scene&"',"&SqlNowString&","&SqlNowString&","&isbest&","&sn&")"
		conn.execute(sql)
		SucMsg=SucMsg&"<li>添加成功!"
		Cenfun_suc("?")
	end if
end if
end sub

sub class_manage()

end sub

sub save_config()
dim cflist,bg,scene,ads,readme,cfversion,copyright,other
	cflist=request("cflist")
		if cflist="" then Errmsg=Errmsg&"<li>播放列表不能为空!请返回重新填写信息!"
	bg=Request("bg")
		if bg="" then Errmsg=Errmsg&"<li>默认背景不能为空!请返回重新填写信息!"
	scene=Request("scene")
		if scene="" then Errmsg=Errmsg&"<li>默认场景不能为空!请返回重新填写信息!"
	ads=Request("ads")
		if ads="" then Errmsg=Errmsg&"<li>公告不能为空!请返回重新填写信息!"
	readme=Request("readme")		
	cfversion=Request("cfversion")
	copyright=Request("copyright")	
	other=Request("other")
	If ErrMsg<>"" Then 
		cenfun_error()
	else
		conn.execute("Update cfplay_config Set cflist='"&cflist&"',bg='"&bg&"',scene='"&scene&"',ads='"&ads&"',readme='"&readme&"',cfversion='"&cfversion&"',copyright='"&copyright&"',other='"&other&"'")
		SucMsg=SucMsg&"<li>修改资料成功!"
		Cenfun_suc("?action=config")
	end if
end sub

Function Checkxml(Str)
	If Isnull(Str) Then
		Checkxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"<","&lt;")
	Str = Replace(Str,">","&gt;")
	Str = Replace(Str,"&","&amp;")
	Str = Replace(Str,"'","&apos;")
	Str = Replace(Str,Chr(34),"&quot;")
	Checkxml = Str
End Function
Function iCheckxml(Str)
	If Isnull(Str) Then
		iCheckxml = ""
		Exit Function 
	End If
	Str = Replace(Str,"&lt;","<")
	Str = Replace(Str,"&gt;",">")
	Str = Replace(Str,"&amp;","&")
	Str = Replace(Str,"&apos;","'")
	'Str = Replace(Str,"&quot;",Chr(34))
	iCheckxml = Str
End Function

sub make_xml()

end sub

function make_file(str,path)
    dim fs,fsowrite
	on error resume next
	Set fs=CreateObject("Scripting.fileSystemObject")
    	Set fsowrite = fs.CreateTextFile(server.MapPath(path),true)
        fsowrite.Write str
        fsowrite.close
		set fsowrite=nothing
	set fs=nothing
	if err.number<>0 then
		response.write "<center>"&Err.Description&"，您的空间不支持FSO，请同您的空间商联系，或者查看相关权限设置。</center>"
	end if
end function

function make_cflist_music(title,url,lrc,content,pic,x,y,w,h,s,a,c,u,scene)
	dim str
		str=str&"<m>"
			str=str&"<n>"&Checkxml(title)&"</n>"
			str=str&"<u>"&Checkxml(url)&"</u>"
			str=str&"<c>"&Checkxml(content)&"</c>"
			str=str&"<p"
			if x<>"" then str=str&" x="""&x&""""
			if y<>"" then str=str&" y="""&y&""""
			if w<>"" then str=str&" w="""&w&""""
			if h<>"" then str=str&" h="""&h&""""
			if s<>"" then str=str&" s="""&s&""""
			if a<>"" then str=str&" a="""&a&""""
			if c<>"" then str=str&" c="""&c&""""
			if u<>"" then str=str&" u="""&u&""""
			str=str&">"&Checkxml(pic)&"</p>"
			str=str&"<l>"&Checkxml(lrc)&"</l>"
			str=str&"<s>"&Checkxml(scene)&"</s>"		
		str=str&"</m>"
	make_cflist_music=str	
end function

sub check_music_name()

end sub

sub make_lrc()

end sub

sub show()

end sub
%>
