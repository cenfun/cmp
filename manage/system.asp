<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
'检测管理员是否登录
If Session(CookieName & "_username")="" or Session(CookieName & "_admin")="" Then
	response.Redirect("index.asp")
else
	header()
	menu()
	Select Case Request.QueryString("action")
		Case "config"
			config()
		Case "save_config"
			save_config()
		Case "remake"
			reMakeData xml_make, xml_path, xml_config, xml_list
		Case "user"
			user()
		Case "edituser"
			edituser()
		Case "saveuser"
			saveuser()
		Case "skins"
			skins()
		Case "saveskins"
			saveskins()
		Case "plugins"
			plugins()
		Case "saveplugins"
			saveplugins()
		Case Else
			config()
	End Select
	footer()
end if

sub config()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form action="system.asp?action=save_config" method="post" onSubmit="return check(this);">
    <tr>
      <th colspan="2" align="left">系统配置：</th>
    </tr>
    <tr>
      <td align="right">CMP主程序：</td>
      <td><input name="cmp_path" type="text" id="cmp_path" value="<%=cmp_path%>" size="50" />
        同级目录下</td>
    </tr>
    <tr>
      <td align="right">站点名称：</td>
      <td><input name="site_name" type="text" id="site_name" value="<%=site_name%>" size="50" /></td>
    </tr>
    <tr>
      <td align="right">站点网址：</td>
      <td><input name="site_url" type="text" id="site_url" value="<%=site_url%>" size="50" /></td>
    </tr>
    <tr>
      <td align="right">管理员QQ：</td>
      <td><input name="site_qq" type="text" id="site_qq" value="<%=site_qq%>" size="50" /></td>
    </tr>
    <tr>
      <td align="right">管理员邮箱：</td>
      <td><input name="site_email" type="text" id="site_email" value="<%=site_email%>" size="50" /></td>
    </tr>
    <tr>
      <td align="right">CMP默认统计(图片方式)：</td>
      <td><input name="site_count" type="text" id="site_count" value="<%=site_count%>" size="50" /></td>
    </tr>
    <tr>
      <td align="right">系统公告：<br />
        (支持html)</td>
      <td><textarea name="site_ads" cols="100" rows="10" id="site_ads"><%=site_ads%></textarea></td>
    </tr>
    <tr>
      <td align="right">是否开启用户注册：</td>
      <td align="left"><input name="user_reg" type="checkbox" id="user_reg" value="1" <%if user_reg="1" then%>checked="checked"<%end if%> />
        如果用户数过多导致服务器负担加重，可关闭注册</td>
    </tr>
    <tr>
      <td align="right">用户注册是否需要审核：</td>
      <td align="left"><input name="user_check" type="checkbox" id="user_check" value="1" <%if user_check="1" then%>checked="checked"<%end if%> />
        开启审核可防止用户恶意注册</td>
    </tr>
    <tr>
      <td align="right" valign="top">是否生成静态XML数据文件：</td>
      <td align="left"><%
	  if CheckObjInstalled("Scripting.FileSystemObject")=false then
	  	xml_make=""
		'开启： regsvr32 scrrun.dll 
		'关闭： regsvr32 /u scrrun.dll
	  %>
        <input name="xml_make" type="checkbox" id="xml_make" value="" disabled="disabled" />
        您的服务器不支持FSO，无法开启此功能
        <%else%>
        <input name="xml_make" type="checkbox" id="xml_make" value="1" <%if xml_make="1" then%>checked="checked"<%end if%> onClick="xmlmake(this);" />
        开启将减轻服务器负担(服务器必须支持FSO)
        <%end if%>
        <div id="xmloption" <%if xml_make<>"1" then%>style="display:none;"<%end if%>>
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td>生成静态数据的文件夹名：</td>
              <td><input name="xml_path" type="text" id="xml_path" value="<%=xml_path%>" />
                当前所占空间：<strong><%=getFolderSize(xml_path)%></strong></td>
            </tr>
            <tr>
              <td>ID匹配配置文件的文件名：</td>
              <td><input name="xml_config" type="text" id="xml_config" value="<%=xml_config%>" /></td>
            </tr>
            <tr>
              <td>ID匹配列表文件的文件名：</td>
              <td><input name="xml_list" type="text" id="xml_list" value="<%=xml_list%>" /></td>
            </tr>
          </table>
        </div>
        <div style="color:#0000FF;">
          <p>注：文件夹名请勿用同级目录下系统已存文件夹名称，如images,data,lrc,skins,plugins等，以防止重建时被一起删除</p>
          <p>ID匹配文件名推荐用config.xml和list.xml，请勿用*.asp,*.asa等服务端程序后缀名，以防止恶意脚本执行</p>
          <p>修改静态数据设置，所有用户静态数据将被重建或全部删除，且CMP调用地址将改变，请务必通知用户</p>
          <p>请勿经常改动静态数据设置，尤其用户过多时，重建所有静态数据将耗费大量服务器资源和时间</p>
        </div></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
    </tr>
  </form>
</table>
<script type="text/javascript">
function xmlmake(o){
	var xmloption = document.getElementById("xmloption");
	if(o.checked){
		xmloption.style.display = "";
	}else{
		xmloption.style.display = "none";
	}
}
function check(o){
	if(o.cmp_path.value==""){
		alert("CMP地址不能为空！");
		o.cmp_path.focus();
		return false;
	}
	if(o.site_name.value==""){
		alert("站点名称不能为空！");
		o.site_name.focus();
		return false;
	}
	if(o.xml_make.checked) {
		if(o.xml_path.value=="" || o.xml_path.value=="images" || o.xml_path.value=="data" || o.xml_path.value=="lrc" || o.xml_path.value=="skins" || o.xml_path.value=="plugins" || !checkbadwords(o.xml_path.value, "./\\:*?<>\"|")){
			alert("生成静态数据的文件夹名不正确！");
			o.xml_path.select();
			return false;
		}
		if(o.xml_config.value=="" || !checkbadwords(o.xml_config.value, "/\\:*?<>\"|")){
			alert("ID匹配配置文件的文件名不正确！");
			o.xml_config.select();
			return false;
		}
		if(o.xml_list.value=="" || !checkbadwords(o.xml_list.value, "/\\:*?<>\"|")){
			alert("ID匹配列表文件的文件名不正确！");
			o.xml_list.select();
			return false;
		}
		if(o.xml_config.value == o.xml_list.value){
			alert("ID匹配配置文件和列表文件的名称不能相同！");
			o.xml_config.select();
			return false;
		}
	}
	return true;
}
</script>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th colspan="2" align="left">数据管理：</th>
  </tr>
  <tr>
    <td align="right" width="20%">手动重建所有静态数据文件：</td>
    <td width="80%"><input name="按钮" type="button" style="width:50px;" value="开始" onclick="window.location='system.asp?action=remake';" /></td>
  </tr>
  
  <tr>
    <td align="right">数据库路径：</td>
    <td><%=Server.MapPath(sitedb)%></td>
  </tr>
  <tr>
    <td align="right">数据库大小：</td>
    <td><%=getFileInfo(sitedb)(0)%></td>
  </tr>
  <tr>
    <td align="right">压缩和修复数据库：</td>
    <td><form action="system.asp?action=config" method="post">
        <input name="dbdo" type="hidden" value="compact" />
        <input type="submit" value="开始" style="width:50px;" />
        推荐经常操作，可以有效地释放无效空间，加快访问速度
      </form>
      <div style="color:#0000FF;">
        <%
if request.Form("dbdo") = "compact" then
	Response.write "关闭所有连接...<br />"
	conn.close
	Response.write "开始压缩和修复数据...<br />"
	dim AccessFSO,AccessEngine
	if CheckObjInstalled("Scripting.FileSystemObject")=true then
		Set AccessFSO=Server.CreateObject("Scripting.FileSystemObject")
		IF AccessFSO.FileExists(Server.Mappath(sitedb)) Then
			Set AccessEngine = CreateObject("JRO.JetEngine")
			AccessEngine.CompactDatabase "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.Mappath(sitedb), "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" & Server.Mappath(sitedb & ".temp")
			AccessFSO.CopyFile Server.Mappath(sitedb & ".temp"),Server.Mappath(sitedb)
			AccessFSO.DeleteFile(Server.Mappath(sitedb & ".temp"))
			Set AccessFSO = Nothing
			Set AccessEngine = Nothing
			Response.write "压缩数据库完成！新的文件大小为："&getFileInfo(sitedb)(0)
		end If
	Else
		Response.write "<span style=""color:#ff0000;"">压缩数据库失败，服务器不支持FSO</span>"
	End if
end if
	  %>
      </div></td>
  </tr>
</table>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">服务器信息：</th>
  </tr>
  <tr>
    <td><div>本机IP：<%=request.servervariables("remote_addr")%> <br/>
        服务器名：<%=Request.ServerVariables("SERVER_NAME")%><br/>
        服务器IP：<%=Request.ServerVariables("LOCAL_ADDR")%><br/>
        服务器端口：<%=Request.ServerVariables("SERVER_PORT")%><br/>
        文件物理路径：<%=server.mappath(Request.ServerVariables("SCRIPT_NAME"))%><br/>
        服务器当前时间：<%=now%><br/>
        IIS版本：<%=Request.ServerVariables("SERVER_SOFTWARE")%><br/>
        脚本超时时间：<%=Server.ScriptTimeout%><br/>
        服务器CPU数量：<%=Request.ServerVariables("NUMBER_OF_PROCESSORS")%><br/>
        服务器解译引擎：<%=ScriptEngine & "/"& ScriptEngineMajorVersion &"."&ScriptEngineMinorVersion&"."& ScriptEngineBuildVersion %><br/>
        服务器操作系统：<%=Request.ServerVariables("OS")%> <br/>
        是否支持FSO：
        <%if CheckObjInstalled("Scripting.FileSystemObject")=false then%>
        否
        <%else%>
        是
        <%end if%>
        <br/>
        支持的文件类型：<%=Request.ServerVariables("HTTP_Accept")%></div></td>
  </tr>
</table>
<%
end sub

sub save_config()
	'cmp_path,site_name,site_url,site_qq,site_email,site_count,site_ads,user_reg,user_check,xml_make,xml_path,xml_config,xml_list
	cmp_path=Checkstr(Request.Form("cmp_path"))
	site_name=Checkstr(Request.Form("site_name"))
	site_url=Checkstr(Request.Form("site_url"))
	site_qq=Checkstr(Request.Form("site_qq"))
	site_email=Checkstr(Request.Form("site_email"))
	site_count=Checkstr(Request.Form("site_count"))
	site_ads=Checkstr(Request.Form("site_ads"))
	user_reg=Request.Form("user_reg")
	user_check=Request.Form("user_check")
	'静态数据设置
	dim xmlmake,xmlpath,xmlconfig,xmllist
	xmlmake=Request.Form("xml_make")
	xmlpath=Checkstr(Request.Form("xml_path"))
	xmlconfig=Checkstr(Request.Form("xml_config"))
	xmllist=Checkstr(Request.Form("xml_list"))
  	sql = "Update cmp_config Set "
	sql = sql & "cmp_path='"&cmp_path&"',site_name='"&site_name&"',site_url='"&site_url&"',site_qq='"&site_qq&"',site_email='"&site_email&"',site_count='"&site_count&"',site_ads='"&site_ads&"',"
	sql = sql & "user_reg='"&user_reg&"',user_check='"&user_check&"',xml_make='"&xmlmake&"',"
	sql = sql & "xml_path='"&xmlpath&"',xml_config='"&xmlconfig&"',xml_list='"&xmllist&"',lasttime="&SqlNowString&""
	'response.Write(sql)
	conn.execute(sql)
	if xmlmake=xml_make and xmlpath=xml_path and xmlconfig=xml_config and xmllist=xml_list then
		SucMsg="修改成功！"
		Cenfun_suc("system.asp?action=config")
	else
		reMakeData xmlmake, xmlpath, xmlconfig, xmllist
	end if
'更新Application信息
Application.Lock
Application(CookieName&"_Arr_system_info")=""
Application.UnLock
end sub

sub reMakeData(xmlmake, xmlpath, xmlconfig, xmllist)
if CheckObjInstalled("Scripting.FileSystemObject")=true then
	dim FSO
	Set FSO=Server.CreateObject("Scripting.FileSystemObject")
	'===================================================================
%>
<div class="output">
  <%if xml_make="1" then%>
  <p>开始清除所有旧的静态数据...</p>
  <%
  	'删除目录
	if FSO.FolderExists(Server.MapPath(xml_path)) then	 	
		FSO.DeleteFolder (Server.MapPath(xml_path))
	end if
  %>
  <p>清理完成！</p>
  <%end if%>
  <%if xmlmake="1" then%>
  <p>开始重建所有静态数据...</p>
  <%
  	'创建新目录
	if not FSO.FolderExists(Server.MapPath(xmlpath)) then
	FSO.CreateFolder(Server.MapPath(xmlpath))
	end if
	'生成文件
	dim num
	num = 0
	dim objStream
	Set objStream = Server.CreateObject("ADODB.Stream")
	If Err.Number=-2147221005 Then 
		ErrMsg = "服务器不支持ADODB.Stream"
		cenfun_error()
		Err.Clear
	else
		sql = "select id,config,list from cmp_user"
		set rs = conn.execute(sql)
			do while not rs.eof
					With objStream
					.Open
					.Charset = "utf-8"
					.Position = objStream.Size
					.WriteText = rs("config")
					.SaveToFile Server.Mappath(xmlpath & "/" & rs("id") & xmlconfig),2 
					.Close
					End With
					With objStream
					.Open
					.Charset = "utf-8"
					.Position = objStream.Size
					.WriteText = rs("list")
					.SaveToFile Server.Mappath(xmlpath & "/" & rs("id") & xmllist),2 
					.Close
					End With
				rs.movenext
				num = num + 2
			loop
		rs.close
		set rs = nothing
	end if
	Set objStream = Nothing
  %>
  <p>重建数据完成！共生成<%=num%>个文件。</p>
  <%end if%>
  <p>
    <input name="" type="button" value="&lt;&lt;返回系统设置" onClick="window.location='system.asp?action=config';" />
  </p>
</div>
<%
	'===================================================================
	Set FSO=Nothing
else
	ErrMsg="服务器不支持FSO，无法重建数据！"
	cenfun_error()
end if
end sub


sub user()
'操作处理
dim idlist
idlist = Checkstr(Request.QueryString("idlist"))
if idlist <> "" then
	select case Request.QueryString("deal")
	case "del"
		conn.execute("delete from cmp_user where id in ("&idlist&")")
	case "lock"
		conn.execute("update cmp_user set userstatus=1 where id in ("&idlist&")")
	case "enable"
		conn.execute("update cmp_user set userstatus=5 where id in ("&idlist&")")
	case else
	end select
	response.Redirect(Request.QueryString("referer"))
	exit sub
end if
'action=user
dim username,userstatus,order,by
username=Checkstr(Request.QueryString("username"))
userstatus=Checkstr(Request.QueryString("userstatus"))
order=Checkstr(Request.QueryString("order"))
by=Checkstr(Request.QueryString("by"))
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <td><span style="float:right;">
      <form onSubmit="return searcher();">
        用户名
        <input type="text" name="username" id="username" value="<%=username%>" />
        <input type="submit" name="search" id="search" value="搜索" />
      </form>
      </span>
      <select onChange="window.location='system.asp?action=user&userstatus='+this.options[this.selectedIndex].value;">
        <option value="">所有用户</option>
        <option value="0" <%if userstatus="0" then%>selected="selected"<%end if%>>未激活用户</option>
        <option value="1" <%if userstatus="1" then%>selected="selected"<%end if%>>被锁定用户</option>
        <option value="5" <%if userstatus="5" then%>selected="selected"<%end if%>>正常用户</option>
      </select>
    </td>
  </tr>
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form>
          <%
'查询串
sql = "select id,username,userstatus,lasttime,email,qq,cmp_name from cmp_user where "
if username <> "" then
	sql = sql & " username like '%"&username&"%' and "
end if
if userstatus <> "" then
	if IsNumeric(userstatus) then
		sql = sql & " userstatus="&userstatus&" and "
	end if
end if
sql = sql & " 1=1 "
if order<>"desc" then
	order = ""
end if
select case by
	case "id"
        sql = sql & " order by id " & order
	case "userstatus"
        sql = sql & " order by userstatus " & order
	case "username"
        sql = sql & " order by username " & order
	case "lasttime"
        sql = sql & " order by lasttime " & order
	case else
		sql = sql & " order by id desc"
		by = "id"
		order = "desc"
end select
'response.Write(sql)
'分页设置
dim page,CurrentPage
page=Checkstr(Request.QueryString("page"))
CurrentPage = 1
if page <> "" then
	if IsNumeric(page) then
		if page > 0 and page < 32768 then
			CurrentPage = cint(page)
		end if
	end if
end if
dim PageC,MaxPerPage
	PageC=0
	MaxPerPage=30
set rs=Server.CreateObject("ADODB.RecordSet")
rs.Open sql,conn,1,1
IF not rs.EOF Then
	rs.PageSize=MaxPerPage
	rs.AbsolutePage=CurrentPage
	Dim rs_nums
	rs_nums=rs.RecordCount
	%>
          <tr>
            <th><input type="checkbox" onClick="CheckAll(this,this.form);" /></th>
            <th><a href="javascript:orderby('userstatus');" title="点击按其排序">状态</a></th>
            <th><a href="javascript:orderby('id');" title="点击按其排序">ID</a></th>
            <th><a href="javascript:orderby('username');" title="点击按其排序">用户名</a></th>
            <th><a href="javascript:orderby('lasttime');" title="点击按其排序">最后登录</a></th>
            <th>Email</th>
            <th>QQ</th>
            <th>播放器</th>
            <th>操作</th>
          </tr>
          <%Do Until rs.EOF OR PageC=rs.PageSize%>
          <%
		dim role,ustatus
		ustatus = rs("userstatus")
		select case ustatus
		case 0
			role = "<strong>未激活</strong>"
		case 1
			role = "<strong style='color:#999999'>被锁定</strong>"
		case 5
			role = "普通用户"
		case 9
			role = "<strong style='color:#0000ff'>管理员</strong>"
		case else
			role = "未定义"
		end select
		%>
          <tr align="center" onMouseOver="highlight(this,'#F9F9F9','#ffffff');">
            <td><%if ustatus<>9 then%>
              <input type="checkbox" name="idlist" id="idlist" value="<%=rs("id")%>" />
              <%end if%></td>
            <td><%=role%></td>
            <td><%=rs("id")%></td>
            <td><a href="system.asp?action=edituser&amp;id=<%=rs("id")%>" title="点击查看和编辑详细资料"><%=rs("username")%></a></td>
            <td><%=FormatDateTime(rs("lasttime"),2)%></td>
            <td><a href="mailto:<%=rs("email")%>" target="_blank"><%=rs("email")%></a></td>
            <td><a href="<%=getQqUrl(rs("qq"))%>" target="_blank"><%=rs("qq")%></a></td>
            <td><a href="<%=getCmpUrl(rs("id"))%>" target="_blank" title="点击在新窗口中打开"><%=rs("cmp_name")%></a></td>
            <td><a href="system.asp?action=edituser&amp;id=<%=rs("id")%>">详情编辑</a></td>
          </tr>
          <%rs.MoveNext%>
          <%PageC=PageC+1%>
          <%loop%>
          <tr>
            <td colspan="10"><div style="float:right;padding-top:5px;"><%=showpage("zh",1,"system.asp?action=user&username="&username&"&userstatus="&userstatus&"&order="&order&"&by="&by&"",rs_nums,MaxPerPage,true,true,"个",CurrentPage)%></div>
              <div style="padding:5px 5px;">
                <input type="button" value="删除" style="width:50px;" onClick="dealuser(this);" title="删除用户不能恢复" />
                <input type="button" value="锁定" style="width:50px;" onClick="dealuser(this);" title="锁定用户" />
                <input type="button" value="激活" style="width:50px;" onClick="dealuser(this);" title="设置为普通用户" />
                (可多选批量操作) </div></td>
          </tr>
          <%
else
%>
          <tr>
            <td><span style="color:#FF0000;">没有找到任何相关记录</span></td>
          </tr>
          <%
end if
rs.Close
Set rs=Nothing
%>
        </form>
      </table></td>
  </tr>
</table>
<script type="text/javascript">
function searcher(){
	var str = document.getElementById("username").value;
	if(str != "<%=username%>"){
		window.location = "system.asp?action=user&username="+str+"&userstatus=<%=userstatus%>&order=<%=order%>&by=<%=by%>";
	}
	return false;
}
function orderby(by){
	var order = "<%=order%>"=="desc"?"":"desc";
	window.location = "system.asp?action=user&username=<%=username%>&userstatus=<%=userstatus%>&order="+order+"&by="+by;
}
function get_idlist(o){
	var ids = new Array();
	var arr = o.idlist;
	if(arr){
		var l = arr.length;
		if(l){
			for(var i = 0; i < l; i++){
				if(arr[i].checked){
					ids.push(arr[i].value);
				}
			}
		}else if(arr.checked){
			ids.push(arr.value);
		}
	}
	return ids;
}
function dealuser(o){
	var str = o.value;
	var id_list = get_idlist(o.form);
	if(id_list.length > 0){
		if(confirm("确定要【"+str+"】以下id所在的项？\n\n"+id_list)){
			if(str == "删除"){
				window.location = "system.asp?action=user&deal=del&idlist="+id_list+"&referer="+escape(window.location);
			}else if(str == "锁定"){
				window.location = "system.asp?action=user&deal=lock&idlist="+id_list+"&referer="+escape(window.location);
			}else if(str == "激活"){
				window.location = "system.asp?action=user&deal=enable&idlist="+id_list+"&referer="+escape(window.location);
			}
		}
	} else {
		alert("请先选择要【"+str+"】的项");
	}
}
</script>
<%
end sub

sub edituser()
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		if id > 0 and id < 32768 then
			id = cint(id)
		else
			ErrMsg = "参数错误"
		end if
	else
		ErrMsg = "参数错误"
	end if
else
	ErrMsg = "参数错误"
end if
if ErrMsg <> "" then
	cenfun_error()
else
	dim referer
	referer = Request.ServerVariables("HTTP_REFERER")
	if referer="" or InStr(LCase(referer),"system.asp?action=user")=0 then
		referer="system.asp?action=user"
	end if
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th colspan="2" align="left"><input type="button" value="&lt;&lt;返回用户列表" onClick="window.location='<%=referer%>';" /></th>
  </tr>
  <%
sql = "select * from cmp_user where id = " & id & " "
set rs = conn.execute(sql)
if not rs.eof then
	dim role,ustatus
	ustatus = rs("userstatus")
	select case ustatus
	case 0
		role = "<strong>未激活</strong>"
	case 1
		role = "<strong style='color:#999999'>被锁定</strong>"
	case 5
		role = "普通用户"
	case 9
		role = "<strong style='color:#0000ff'>管理员</strong>"
	case else
		role = "未定义"
	end select
	dim cmpurl
	cmpurl = getCmpUrl(rs("id"))
%>
  <form method="post" action="system.asp?action=saveuser&id=<%=rs("id")%>" onSubmit="return check(this);">
    <tr>
      <th colspan="2" align="left">详细资料:</th>
    </tr>
    <tr>
      <td align="right">ID：</td>
      <td><%=rs("id")%></td>
    </tr>
    <tr>
      <td align="right">状态：</td>
      <td><%=role%></td>
    </tr>
    <tr>
      <td align="right">用户名：</td>
      <td><%=rs("username")%></td>
    </tr>
    <%if ustatus <> 9 then%>
    <tr>
      <td align="right">密码：</td>
      <td><input name="password" type="password" id="password" size="30" />
        一般用于帮用户重置密码，不修改请留空。</td>
    </tr>
    <%end if%>
    <tr>
      <td align="right">注册日期：</td>
      <td><%=rs("regtime")%></td>
    </tr>
    <tr>
      <td align="right">最后登录日期：</td>
      <td><%=rs("lasttime")%></td>
    </tr>
    <tr>
      <td align="right">最后访问IP：</td>
      <td><%=rs("lastip")%> <a href="<%=getIpUrl(rs("lastip"))%>" target="_blank">查询</a></td>
    </tr>
    <tr>
      <td align="right">登录次数：</td>
      <td><input name="logins" type="text" id="logins" size="30" maxlength="50" value="<%=rs("logins")%>" /></td>
    </tr>
    <tr>
      <td align="right">点击次数：</td>
      <td><input name="hits" type="text" id="hits" size="30" maxlength="50" value="<%=rs("hits")%>" /></td>
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
      <td align="right">播放器地址：</td>
      <td><a href="<%=cmpurl%>" target="_blank"><%=cmpurl%></a></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" />
      </td>
    </tr>
  </form>
  <%
end if
rs.close
set rs = nothing
%>
</table>
<script type="text/javascript">
function check(o){
	if(o.logins.value=="" || isNaN(o.logins.value)){
		alert("登录次数必须为数字！");
		o.logins.focus();
		return false;
	}
	if(o.hits.value=="" || isNaN(o.hits.value)){
		alert("登录次数必须为数字！");
		o.hits.focus();
		return false;
	}
	if(o.cmp_name.value==""){
		alert("播放器名称不能为空！");
		o.cmp_name.focus();
		return false;
	}
	return true;
}
</script>
<%
end if
end sub

sub saveuser()
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		'修改用户信息
		sql = "select username from cmp_user where id="&id
		set rs = conn.execute(sql)
		if not rs.eof then
			dim password,logins,hits,email,qq,cmp_name,cmp_url
			if Request.Form("password")<>"" then
				password=md5(Request.Form("password")+rs("username"),16)
				conn.execute("update cmp_user set [password]='"&password&"' where username='"&rs("username")&"'")
			end if
			logins=Checkstr(Request.Form("logins"))
			hits=Checkstr(Request.Form("hits"))
			email=Checkstr(Request.Form("email"))
			qq=Checkstr(Request.Form("qq"))
			cmp_name=Checkstr(Request.Form("cmp_name"))
			cmp_url=Checkstr(Request.Form("cmp_url"))
			sql = "update cmp_user set logins="&logins&",hits="&hits&",email='"&email&"',qq='"&qq&"',cmp_name='"&cmp_name&"',cmp_url='"&cmp_url&"' "
			sql = sql & " where username='"&rs("username")&"'"
			'response.Write(sql)
			conn.execute(sql)
			SucMsg="修改成功！"
			Cenfun_suc(Request.ServerVariables("HTTP_REFERER"))
		end if
		rs.close
		set rs = nothing
	end if
end if
end sub

sub skins()
end sub

sub saveskins()
end sub

sub plugins()
end sub

sub saveplugins()
end sub
%>
