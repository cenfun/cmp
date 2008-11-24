<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
site_title = "管理中心"
'检测用户是否登录
If founduser Then
	Select Case Request.QueryString("handler")
		Case "savelrcdata"
			savelrcdata()
		Case "savelistdata"
			savelistdata()
		Case "saveconfigdata"
			saveconfigdata()
		Case "getskins"
			getskins()
		Case "getplugins"
			getplugins()
		Case "getlrcs"
			getlrcs()
		Case Else
			header()
			menu()
			Select Case Request.QueryString("action")
				Case "userinfo"
					userinfo()
				Case "saveinfo"
					saveinfo()	
				Case "config"
					config()
				Case "saveconfig"
					saveconfig()
				Case "list"
					list()
				Case "savelist"
					savelist()
				Case Else
					main()
			End Select
			footer()
	 End Select
else 
	response.Redirect("index.asp")
end if


sub savelrcdata()
	Response.Charset = "utf-8"
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
		exit sub
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
		Exit sub
	end if
	'超出大小跳出
	if maxsize>0 then
		if formsize>maxsize then
			Response.Write("uploadError{|}文件大小("&formsize&")超过限制" & maxsize)
			Response.End()
			exit sub
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
			
			'扩展类型是否符合要求，仅保存txt和lrc类型
			dim ext
			ext = LCase(Right(filename, 4))
			if ext=".lrc" or ext=".txt" then
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
				if Err then
					Err.clear
					'服务器已经存在此文件
					Response.Write("uploadError{|}写入文件失败，可能服务器已经存在此文件，请尝试更换文件名再上传")
					Response.End()
					exit sub
				else
				
					'保存新增路径到数据库
		
					'如果没有重复记录
					conn.execute("insert into cmp_lrc (src) values('"&filename&"')")
	
					Response.Write("uploadComplete{|}" & fileurl)
					Response.End()
				end if
				
			else
				Response.Write("uploadError{|}仅支持*lrc和.txt类型的文件")
				Response.End()
				exit sub
			end if
			
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



sub getskins()
addUTFBOM()
dim userid,cmp_show_url
userid = Session(CookieName & "_userid")
cmp_show_url = getCmpUrl(userid)
dim skinlist
skinlist = "<cmp_skins>"
sql = "select * from cmp_skins order by id desc"
set rs = conn.execute(sql)
if not rs.eof then
	Do Until rs.EOF
		'<skin src="skins/wmp11.zip" mixer_id="" mixer_color="" show_tip="" />
		skinlist = skinlist & "<skin title=""" & XMLEncode(rs("title")) & """ "
		skinlist = skinlist & "preview=""" & cmp_show_url & "&amp;skin_src=" & XMLEncode(rs("src")) & """ "
		skinlist = skinlist & "src=""" & XMLEncode(rs("src")) & """ "
		skinlist = skinlist & "bgcolor=""" & XMLEncode(rs("bgcolor")) & """ "
		skinlist = skinlist & "mixer_id=""" & XMLEncode(rs("mixer_id")) & """ "
		skinlist = skinlist & "mixer_color=""" & XMLEncode(rs("mixer_color")) & """ "
		skinlist = skinlist & "show_tip=""" & XMLEncode(rs("show_tip")) & """ />"
	rs.MoveNext
    loop
end if
rs.close
set rs = nothing
skinlist = skinlist & "</cmp_skins>"
Response.Write(skinlist)
end sub

sub getplugins()
addUTFBOM()
dim pluginlist
pluginlist = "<cmp_plugins>"
sql = "select * from cmp_plugins order by id desc"
set rs = conn.execute(sql)
if not rs.eof then
	Do Until rs.EOF
		'<plugin name="大背景" xywh="0, 0, 100P, 100P" src="plugins/bigbg.swf" lock="1" display="1" istop="0" />
		pluginlist = pluginlist & "<plugin title=""" & XMLEncode(rs("title")) & """ "
		pluginlist = pluginlist & "src=""" & XMLEncode(rs("src")) & """ "
		pluginlist = pluginlist & "xywh=""" & XMLEncode(rs("xywh")) & """ "
		pluginlist = pluginlist & "lock=""" & rs("lock") & """ "
		pluginlist = pluginlist & "display=""" & rs("display") & """ "
		pluginlist = pluginlist & "istop=""" & rs("istop") & """ />"
	rs.MoveNext
    loop
end if
rs.close
set rs = nothing
pluginlist = pluginlist & "</cmp_plugins>"
Response.Write(pluginlist)
end sub

sub config()
dim strContent,id
sql = "select id,cmp_name,cmp_url,config from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
	id = rs("id")
	if trim(rs("config"))<>"" then
		strContent = UnCheckStr(rs("config"))
		'正则替换配置文件列表地址，名称，网站
		strContent = setLNU(strContent, xml_make, xml_path, xml_list, id, rs("cmp_name"), rs("cmp_url"))
	else
		dim cr,lPath
		cr = Chr(13) & Chr(10)  & Chr(13) & Chr(10) 
		if xml_make="1" then
			lPath = xml_path & "/" & id & xml_list
		else
			lPath = "list.asp?id="&id
		end if
		strContent = "<cmp name="""&rs("cmp_name")&""" url="""&rs("cmp_url")&""" list="""&lPath&""" >" & cr
		strContent = strContent & "<config language="""" play_mode="""" skin_id="""" list_id="""" volume="""" auto_play="""" max_video="""" bgcolor="""" "
		strContent = strContent & "mixer_id="""" mixer_color="""" mixer_filter="""" mixer_displace="""" "
		strContent = strContent & "buffer="""" timeout="""" show_tip="""" context_menu="""" video_smoothing="""" plugins_disabled="""" check_policyfile=""""  />" & cr
		strContent = strContent & "<skins>"&cr&"</skins>" & cr 
		strContent = strContent & "<plugins>"&cr&"</plugins>" & cr
		strContent = strContent & "<nolrc src="""">"&cr&"</nolrc>" & cr
		strContent = strContent & "<count src="""&XMLEncode(site_count)&""" />" & cr
		strContent = strContent & "</cmp>"
		'更新配置至数据库
		conn.execute("update cmp_user set config='"&CheckStr(strContent)&"' where id=" & id & " ")
	end if
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">CMP配置文件编辑: <span style="margin-left:20px;font-weight:normal;">
      <%if request.QueryString("mode")="code" then%>
      <input type="button" onclick="window.location='manage.asp?action=config';" value="&lt;&lt;返回普通编辑模式" />
      <%else%>
      <input type="button" onclick="window.location='manage.asp?action=config&mode=code';" value="进入代码编辑模式&gt;&gt;" />
      <%end if%>
      </span></th>
  </tr>
  <%if request.QueryString("mode")="code" then%>
  <form method="post" action="manage.asp?action=saveconfig" onsubmit="return check_config(this);">
    <tr>
      <td align="center"><textarea name="config" rows="30" id="config" style="width:99%;"><%=strContent%></textarea></td>
    </tr>
    <tr>
      <td align="center"><input name="config_submit" type="submit" style="width:50px;" value="提交" />
        <input name="config_check" type="button" style="width:50px;" onclick="check_xml(this);" value="检测" /></td>
    </tr>
  </form>
  <%else%>
  <tr>
    <td align="center"><script type="text/javascript">
var vars = "";
vars += "i=config.asp%3Fid%3D<%=id%>%26rd%3D"+Math.random();
vars += "&o=manage.asp%3Fhandler%3Dsaveconfigdata";
vars += "&sl=manage.asp%3Fhandler%3Dgetskins%26rd%3D"+Math.random();
vars += "&pl=manage.asp%3Fhandler%3Dgetplugins%26rd%3D"+Math.random();
//id, width, height, cmp url, vars
showcmp("cmp_config_editer", "100%", "600", "CConfig.swf", vars, false);
</script>
    </td>
  </tr>
  <%end if%>
</table>
<script type="text/javascript">
function check_xml(o) {
	if (check_config(o.form)) {
		alert("XML格式正确！");
	}
}
function check_config(o){
	var str = o.config.value;
	var chk = checkXML(str);
	var isok = chk[0];
	var xmlDoc = chk[1];
	//检测列表是否为空
	if (isok) {
		var root = xmlDoc.documentElement;
		if (!root.getAttribute("list")) {
			isok = false;
			alert("必须配置对应的列表路径list");
		}
	}
	return isok;
}
</script>
<%
end sub

sub saveconfig()
	dim config,id
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		config = CheckStr(request.Form("config"))
		conn.execute("update cmp_user set config='"&config&"' where id=" & id & " ")
		SucMsg="修改成功！"
		Cenfun_suc("manage.asp?action=config&mode=code")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_config, UnCheckStr(config))
		end if
	else
		ErrMsg = "用户不存在或者被锁定！"
		cenfun_error()
	end if
	rs.close
	set rs = nothing
end sub

sub saveconfigdata()
	dim config,id
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		config = CheckStr(request.Form("config"))
		conn.execute("update cmp_user set config='"&config&"' where id=" & id & " ")
		Response.Write("CMPConfigComplete")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_config, UnCheckStr(config))
		end if
	end if
	rs.close
	set rs = nothing
end sub

sub list()
dim strContent,id
sql = "select id,list from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
	id = rs("id")
	if trim(rs("list"))<>"" then
		strContent = UnCheckStr(rs("list"))
	else
		strContent = "<list>" & Chr(13) & Chr(10) & "</list>"
	end if
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left"><span style="float:right;margin-right:5px;">
      <div>
        <div align="right">
          <form onsubmit="return getLrcList();">
            <input id="lrc_name" type="text" size="35" title="最多搜索出5个结果，请输入适当的关键字，以便更精确的查找歌词" />
            <input type="submit" value="搜索歌词" />
          </form>
        </div>
        <div id="lrclist"></div>
        <div id="lrcupload" style="display:none;">
          <script type="text/javascript">
var vars = "";
vars += "url=manage.asp%3Fhandler%3Dsavelrcdata";
vars += "&type=txt,lrc";
vars += "&max=50000";
document.write(getcmp("lrcupload", "500", "26", "upload.swf", vars));
          </script>
          <div>注意：仅支持上传 *.lrc 和 *.txt 的歌词文件</div>
        </div>
      </div>
      </span>CMP列表文件编辑: <span style="margin-left:20px;font-weight:normal;">
      <%if request.QueryString("mode")="code" then%>
      <input type="button" onclick="window.location='manage.asp?action=list';" value="&lt;&lt;返回普通编辑模式" />
      <%else%>
      <input type="button" onclick="window.location='manage.asp?action=list&mode=code';" value="进入代码编辑模式&gt;&gt;" />
      <%end if%>
      </span></th>
  </tr>
  <%if request.QueryString("mode")="code" then%>
  <form method="post" action="manage.asp?action=savelist" onsubmit="return check_list(this);">
    <tr>
      <td align="center"><textarea name="list" rows="30" id="list" style="width:99%;"><%=strContent%></textarea></td>
    </tr>
    <tr>
      <td align="center"><input name="list_submit" type="submit" style="width:50px;" value="提交" />
        <input name="list_check" type="button" style="width:50px;" onclick="check_xml(this);" value="检测" /></td>
    </tr>
  </form>
  <%else%>
  <tr>
    <td align="center"><script type="text/javascript">
var vars = "";
vars += "i=list.asp%3Fid%3D<%=id%>%26rd%3D"+Math.random();
vars += "&o=manage.asp%3Fhandler%3Dsavelistdata";
//id, width, height, cmp url, vars
showcmp("cmp_list_editer", "100%", "600", "CList.swf", vars, false);
</script>
    </td>
  </tr>
  <%end if%>
</table>
<script type="text/javascript">
function getLrcList() {
	showUpload(false);
	var lrc_name = document.getElementById("lrc_name");
	if (lrc_name.value) {
		ajaxSend("GET","manage.asp?rd="+Math.random()+"&handler=getlrcs&lrc_name="+encodeURIComponent(lrc_name.value),true,null,completeHd,errorHd);
	} else {
		completeHd("");
	}
	return false;
}
function completeHd(data) {
	//alert(data);
	var obj = document.getElementById("lrclist");
	if(data != ""){
		var html = '<table border="0" cellpadding="2" cellspacing="1" >';
		if (data == "null") {
			html += '<tr><td>没有找到相关的歌词！<a href="javascript:showUpload(true);void(0);">上传歌词</a></td></tr>';
		} else {
			var lrcs = data.split("{|}");
			for (var i = 0; i < lrcs.length - 1; i ++) {
				var url = "lrc/"+lrcs[i];
				html += '<tr><td><a href="'+url+'" target="_blank">查看</a> <input value="'+url+'" onfocus="this.select();" size="60" /></td></tr>';
			}
			html += '<tr><td align="center">请复制输入框中的歌词路径，粘贴到列表编辑器中即可！ <a href="javascript:showList(false);void(0);">关闭</a></td></tr>';
		}
		html += '</table>';
		//
		showList(true);
		obj.innerHTML = html;
	} else {
		showList(false);
	}
}
function showList(show) {
	var obj = document.getElementById("lrclist");
	if (show) {
		obj.style.display = "";
	} else {
		obj.style.display = "none";
	}
}
function errorHd(errmsg) {
	alert(errmsg);
}
function showUpload(show) {
	var lrcupload = document.getElementById("lrcupload");
	if (show) {
		lrcupload.style.display = "";
	} else {
		lrcupload.style.display = "none";
	}
}
function check_xml(o) {
	if (check_list(o.form)) {
		alert("XML格式正确！");
	}
}
//检测列表文件格式
function check_list(o){
	var str = o.list.value;
	var chk = checkXML(str);
	var isok = chk[0];
	var xmlDoc = chk[1];
	//是否有l专辑标记
	if (isok) {
		var root = xmlDoc.documentElement;
		if (root.childNodes.length) {
			var tagL = xmlDoc.firstChild.getElementsByTagName("l");
			if (tagL.length == 0) {
				isok = false;
				alert(errMsg + "至少需要一个l标记的分类");
			}
		}
	}
	return isok;
}
</script>
<%
end sub

sub getlrcs()
	dim lrc_name
	lrc_name = CheckStr(Request.QueryString("lrc_name"))
	if lrc_name="" then
		Response.Write("null")
	else
		'模糊搜索
		sql = "select top 5 src from cmp_lrc where 1=1 "
		dim keywords,key
		keywords = Split(lrc_name, " ")
		For Each key in keywords
    		sql = sql & " and src like '%"&key&"%' "
		Next
		set rs=conn.Execute(sql)
		if rs.eof then
			Response.Write("null")
		else
			Do Until rs.EOF
				Response.Write(trim(rs("src")) & "{|}")
				rs.MoveNext
			loop
		end if
		rs.close
		set rs=nothing
	end if
end sub

sub savelist()
	dim list,id
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		list = CheckStr(request.Form("list"))
		conn.execute("update cmp_user set list='"&list&"' where id=" & id & " ")
		SucMsg="修改成功！"
		Cenfun_suc("manage.asp?action=list&mode=code")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_list, UnCheckStr(list))
		end if
	else
		ErrMsg = "用户不存在或者被锁定！"
		cenfun_error()
	end if
	rs.close
	set rs = nothing
end sub

sub savelistdata()
	dim list,id
	sql = "select id from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
	set rs = conn.execute(sql)
	if not rs.eof then
		id = rs("id")
		list = CheckStr(request.Form("list"))
		conn.execute("update cmp_user set list='"&list&"' where id=" & id & " ")
		Response.Write("CMPListComplete")
		'重建静态数据
		if xml_make="1" then
			call makeFile(xml_path & "/" & id & xml_list, UnCheckStr(list))
		end if
	end if
	rs.close
	set rs = nothing
end sub


sub userinfo()
sql = "select * from cmp_user where username = '" & Session(CookieName & "_username") & "' and userstatus > 4 "
set rs = conn.execute(sql)
if not rs.eof then
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveinfo&do=info" onsubmit="return check_info(this);">
    <tr>
      <th colspan="2" align="left">个人资料:</th>
    </tr>
    <tr>
      <td align="right">用户名：</td>
      <td><%=rs("username")%></td>
    </tr>
    <tr>
      <td align="right">注册日期：</td>
      <td><%=rs("regtime")%></td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap">最后登录日期：</td>
      <td><%=rs("lasttime")%></td>
    </tr>
    <tr>
      <td align="right">最后访问IP：</td>
      <td><%=rs("lastip")%> <a href="<%=getIpUrl(rs("lastip"))%>" target="_blank">查询</a></td>
    </tr>
    <tr>
      <td align="right">登录次数：</td>
      <td><%=rs("logins")%></td>
    </tr>
    <tr>
      <td align="right">Email：</td>
      <td><input name="email" type="text" id="email" size="30" maxlength="50" value="<%=rs("email")%>" /></td>
    </tr>
    <tr>
      <td align="right">QQ：</td>
      <td><input name="qq" type="text" id="qq" size="30" maxlength="50" value="<%=rs("qq")%>" /></td>
    </tr>
    <tr>
      <td align="right">播放器名称：</td>
      <td><input name="cmp_name" type="text" id="cmp_name" size="50" maxlength="200" value="<%=rs("cmp_name")%>" /></td>
    </tr>
    <tr>
      <td align="right">网址：</td>
      <td><input name="cmp_url" type="text" id="cmp_url" size="50" maxlength="200" value="<%=rs("cmp_url")%>" /></td>
    </tr>
    <tr>
      <td align="right">不公开到用户列表：</td>
      <td><input name="setinfo" type="checkbox" value="1" <%if rs("setinfo")=1 then%>checked="checked"<%end if%> /></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
    </tr>
  </form>
</table>
<%
else
	ErrMsg = "用户不存在或者被锁定！"
	cenfun_error()
end if
rs.close
set rs = nothing
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveinfo&do=pass" onsubmit="return check_pass(this);">
    <tr>
      <th colspan="2" align="left">修改密码:</th>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap">原有密码：</td>
      <td><input name="oldpassword" type="password" id="oldpassword" size="20" /></td>
    </tr>
    <tr>
      <td align="right">新密码：</td>
      <td><input name="newpassword" type="password" id="newpassword" size="20" /></td>
    </tr>
    <tr>
      <td align="right">确认密码：</td>
      <td><input name="passwordcheck" type="password" id="passwordcheck" size="20" /></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_info(o){
	if(o.qq.value!=""){
		if(isNaN(o.qq.value)){
			alert("QQ号码必须为数字！");
			o.qq.select();
			return false;
		}
	}
	if(o.cmp_name.value==""){
		alert("播放器名称不能为空！");
		o.cmp_name.focus();
		return false;
	}
	return true;
}	
function check_pass(o){
	if(o.oldpassword.value==""){
		alert("原有密码不能为空！");
		o.oldpassword.focus();
		return false;
	}
	if(o.newpassword.value==""){
		alert("新密码不能为空！");
		o.newpassword.focus();
		return false;
	}
	if(o.passwordcheck.value==""){
		alert("确认密码不能为空！");
		o.passwordcheck.focus();
		return false;
	}
	if(o.newpassword.value!=o.passwordcheck.value){
		alert("确认密码和新密码不一致，请重新输入！");
		o.newpassword.focus();
		o.newpassword.value = "";
		o.passwordcheck.value = "";
		return false;
	}
	return true;
}	
</script>
<%if Session(CookieName & "_username") = Session(CookieName & "_admin") then%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form method="post" action="manage.asp?action=saveinfo&do=name" onsubmit="return check_name(this);">
    <tr>
      <th colspan="2" align="left">修改用户名:</th>
    </tr>
    <tr>
      <td align="right">密码：</td>
      <td><input name="password" type="password" id="password" size="20" />
        必须输入当前用户密码才能修改</td>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap">用户名：</td>
      <td><input name="username" type="text" id="username" size="20" maxlength="200" value="<%=Session(CookieName & "_admin")%>" />
        仅管理员可修改</td>
    </tr>
    <tr>
      <td align="right">注：</td>
      <td>请不要使用常见的管理员名，如admin等，以防止恶意破解；<br />
        请务必牢记修改后的用户名，如果忘记请打开数据库查阅。</td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function check_name(o){
	if(o.password.value==""){
		alert("用户密码不能为空！");
		o.password.focus();
		return false;
	}
	if(o.username.value==""){
		alert("用户名不能为空！");
		o.username.focus();
		return false;
	}
	return true;
}	
</script>
<%end if%>
<%
end sub

sub saveinfo()
dim username
username = Session(CookieName & "_username")
if Request.QueryString("do")="info" then
	'修改用户信息
	dim email,qq,cmp_name,cmp_url,setinfo,config
	email=Checkstr(Request.Form("email"))
	qq=Checkstr(Request.Form("qq"))
	cmp_name=Checkstr(Request.Form("cmp_name"))
	cmp_url=Checkstr(Request.Form("cmp_url"))
	setinfo=Checkstr(Request.Form("setinfo"))
	if setinfo<>"" then
		setinfo=1
	else
		setinfo=0
	end if
	
	set rs = conn.execute("select id,config from cmp_user where username='"&username&"' ")
	'正则替换配置文件列表地址，名称，网站
	config = setLNU(UnCheckStr(rs("config")), xml_make, xml_path, xml_list, rs("id"), cmp_name, cmp_url)
	'重建静态数据
	if xml_make="1" then
		call makeFile(xml_path & "/" & rs("id") & xml_config, config)
	end if
	rs.close
	set rs = nothing
	'保存到数据库
	sql = "update cmp_user set email='"&email&"',qq='"&qq&"',cmp_name='"&cmp_name&"',cmp_url='"&cmp_url&"',setinfo="&setinfo&",config='"&CheckStr(config)&"' where username='"&username&"'"
	'response.Write(sql)
	conn.execute(sql)
	
	SucMsg="修改成功！"
	Cenfun_suc("manage.asp?action=userinfo")
elseif Request.QueryString("do")="pass" then
	'修改用户密码
	dim oldpassword,newpassword
	oldpassword=md5(request.Form("oldpassword")+username,16)
	sql = "select id from cmp_user where username='"&username&"' and password='"&oldpassword&"'"
	set rs=conn.Execute(sql)
	if not rs.eof then
		newpassword=md5(request.Form("newpassword")+username,16)
		conn.execute("update cmp_user set [password]='"&newpassword&"' where username='"&username&"'")
		SucMsg="修改成功！"
		Cenfun_suc("manage.asp?action=userinfo")
	else
		ErrMsg = "您输入的原密码错误，请返回重试"
		cenfun_error()
	end if
	rs.close
	set rs=nothing
elseif Request.QueryString("do")="name" then
	if username = Session(CookieName & "_admin") then
		'修改新用户名
		dim password,newusername,updatepassword
		newusername=Checkstr(Request.Form("username"))
		if newusername <> username then
			'验证密码
			password=md5(request.Form("password")+username,16)
			sql = "select id from cmp_user where username='"&username&"' and password='"&password&"'"
			set rs=conn.Execute(sql)
			if not rs.eof then
				'验证重名
				dim cenfun
				sql = "select username from cmp_user where username='"&newusername&"' "
				set cenfun=conn.Execute(sql)
				if cenfun.eof then
					'更新对应的密码
					updatepassword=md5(request.Form("password")+newusername,16)
					conn.execute("update cmp_user set username='"&newusername&"',[password]='"&updatepassword&"' where username='"&username&"'")
					Session(CookieName & "_username") = newusername
					Session(CookieName & "_admin") = newusername
					SucMsg="修改成功！"
					Cenfun_suc("manage.asp?action=userinfo")
				else
					ErrMsg = "您输入的用户名已经存在，请返回重试"
					cenfun_error()
				end if
				cenfun.close
				set cenfun=nothing
			else
				ErrMsg = "您输入的原密码错误，请返回重试"
				cenfun_error()
			end if
			rs.close
			set rs=nothing
		else
			ErrMsg = "用户名没有任何变化"
			cenfun_error()
		end if
	end if
end if
end sub


sub main()
dim userid,cmp_url,cmp_page_url
userid = Session(CookieName & "_userid")
cmp_url = getCmpUrl(userid)
cmp_page_url = getCmpPageUrl(userid)
%>
<table border="0" cellpadding="3" cellspacing="2" class="tableborder" width="98%">
  <tr>
    <th colspan="2" align="left">调用代码：</th>
  </tr>
  <tr>
    <td width="10%" align="right">CMP调用地址：</td>
    <td width="90%"><a href="<%=cmp_url%>&amp;c.swf" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_url%>&amp;c.swf</strong></a></td>
  </tr>
  <tr>
    <td align="right">页面地址：</td>
    <td><a href="<%=cmp_page_url%>" target="_blank" title="点击在新窗口中打开"><strong><%=cmp_page_url%></strong></a></td>
  </tr>
  <tr>
    <td align="right" nowrap="nowrap">常用论坛调用标签：</td>
    <td>[flash=100%,600]<%=cmp_url%>&amp;c.swf[/flash]</td>
  </tr>
  <tr>
    <td align="right" nowrap="nowrap">内框架页面调用：</td>
    <td>&lt;iframe frameborder=&quot;0&quot; scrolling=&quot;no&quot; src=&quot;<%=cmp_page_url%>&quot; width=&quot;100%&quot; height=&quot;600&quot;&gt;&lt;/iframe&gt;</td>
  </tr>
  <tr>
    <td align="right">HTML调用代码：</td>
    <td><textarea id="html_code" name="html_code" style="width:99%;" wrap="virtual" rows="12" onfocus="this.select();"></textarea></td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>默认宽100%高600</td>
  </tr>
</table>
<script type="text/javascript">
function show_code() {
	html = getcmp("cmp<%=userid%>", "100%", "600", "<%=cmp_url%>&c.swf", "");
	var textarea = document.getElementById("html_code");
	textarea.value = html;
}
show_code();
</script>
<%
end sub
%>
