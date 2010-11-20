<!--#include file="conn.asp"-->
<!--#include file="const.asp"--> 
<!--#include file="md5.asp"-->
<%
site_title = "系统管理"

'检测管理员是否登录
If founduser and foundadmin Then
	if Request.QueryString("handler")="ajax" then
		ajax()
	else
		header()
		menu()
		top_menu()
		Select Case Request.QueryString("action")
			Case "config"
				config()
			Case "save_config"
				save_config()
			Case "update_config"
				update_config()
			Case "remake"
				call reMakeData(xml_make, xml_path, xml_config, xml_list)
			Case "user"
				user()
			Case "edituser"
				edituser()
			Case "saveuser"
				saveuser()
			Case "skins"
				skins()
			Case "plugins"
				plugins()
			Case Else
				config()
		End Select
		footer()
	end if
else
	header()
	ErrMsg = "用户未登录或超时退出，请<a href=""index.asp"">重新登录</a>！"
	cenfun_error()
end if
	
	
sub top_menu()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder menu_bar" width="98%">
  <tr>
    <td><div class="clearfix">
        <div class="lt"><a href="system.asp?action=config" title="System">系统设置</a></div>
        <div class="lt"><a href="system.asp?action=user" title="Users">用户管理</a></div>
        <div class="lt"><a href="system.asp?action=skins" title="Skins">皮肤管理</a></div>
        <div class="lt"><a href="system.asp?action=plugins" title="Plugins">插件管理</a></div>
      </div></td>
  </tr>
</table>
<%
end sub	

	
sub ajax()
	Select Case Request.QueryString("cmd")
		Case "clear"
			'删除目录
			delFolder(Request.QueryString("xmlpath"))
		Case "create"
			'创建新目录
			makeFolder(Request.QueryString("xmlpath"))
		Case "make"	
			dim xmlpath,xmlconfig,xmllist
			xmlpath = Trim(Request.QueryString("xmlpath"))
			xmlconfig = Trim(Request.QueryString("xmlconfig"))
			xmllist = Trim(Request.QueryString("xmllist"))
			'生成文件
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
				MaxPerPage=20
			sql = "select id,config,list from cmp_user where userstatus > 4"
			set rs=Server.CreateObject("ADODB.RecordSet")
			rs.Open sql,conn,1,1
			IF not rs.EOF Then
				Dim rs_nums,now_num
				'记录总数
				rs_nums=rs.RecordCount
				'当前页数之前的总数
				now_num=CurrentPage * MaxPerPage
				if now_num < rs_nums then
					rs.PageSize=MaxPerPage
					rs.AbsolutePage=CurrentPage
					dim re,strContent,id
					Set re=new RegExp
					re.IgnoreCase =True
					re.Global=True
					re.Pattern="(<cmp[^>]+list *= *\"")[^\r]*?(\""[^>]*>)"
					Do Until rs.EOF OR PageC=rs.PageSize
						id = rs("id")
						strContent = UnCheckStr(rs("config"))
						strContent=re.Replace(strContent,"$1" & xmlpath & "/" & id & xmllist & "$2")
						call makeFile(xmlpath & "/" & id & xmlconfig, strContent)
						call makeFile(xmlpath & "/" & id & xmllist, UnCheckStr(rs("list")))
						rs.MoveNext
						PageC=PageC+1
					loop
					Set re=nothing
					Response.Write(CurrentPage)			
				else
					Response.Write("MakeComplete")
				end if
			else
				Response.Write("MakeComplete")
			end if
			rs.Close
			Set rs=Nothing
		Case "fixmdb"
			'关闭连接
			conn.close
			'关闭站点
			Application.Lock
			Application(CookieName&"_site_close")="1"
			Application.UnLock
			'开始压缩和修复数据
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
			'打开站点
			Application.Lock
			Application(CookieName&"_site_close")=""
			Application.UnLock
		Case Else
		
	End Select
end sub

sub reMakeData(xmlmake, xmlpath, xmlconfig, xmllist)
%>
<div class="output" align="center">
  <div id="step_clear" style="display:none;">
    <p>开始清除所有旧的静态数据... <strong id="step_clear_msg"><img src="images/loading.gif" align="absmiddle" /></strong></p>
  </div>
  <div id="step_create" style="display:none;">
    <p>开始创建新的静态数据目录... <strong id="step_create_msg"><img src="images/loading.gif" align="absmiddle" /></strong></p>
  </div>
  <div id="step_make" style="display:none;">
    <p>开始生成所有静态数据文件... <strong id="step_make_msg"><img src="images/loading.gif" align="absmiddle" /></strong></p>
  </div>
  <div id="step_end" style="display:none;">
    <p>
      <input name="" type="button" value="&lt;&lt;返回系统设置" onClick="window.location='system.asp?action=config';" />
    </p>
  </div>
</div>
<script type="text/javascript">
//新的设置
var xmlmake = "<%=xmlmake%>";
var xmlpath = "<%=xmlpath%>";
var xmlconfig = "<%=xmlconfig%>";
var xmllist = "<%=xmllist%>";
//旧的设置
var xml_make = "<%=xml_make%>";
var xml_path = "<%=xml_path%>";
var xml_config = "<%=xml_config%>";
var xml_list = "<%=xml_list%>";
//当前页
var now_page = 1;
if (xml_make == "1") {
	//如果存在之前旧的数据则清理
	show_step("step_clear");
	//直接删除之前数据目录xml_path
	$.get("system.asp?rd="+Math.random()+"&handler=ajax&cmd=clear&xmlpath="+xml_path, function(data){
		var msg = "完成";
		if(data != ""){
			msg = data;
		}
		show_msg("step_clear_msg", msg);
		start_make();
	});
} else {
	start_make();
}

function start_make() {
	if (xmlmake == "1") {
		show_step("step_create");
		//创建新的数据目录xmlpath
		$.get("system.asp?rd="+Math.random()+"&handler=ajax&cmd=create&xmlpath="+xmlpath, function(data){
			var msg = "完成";
			if(data != ""){
				msg = data;
			} 
			show_msg("step_create_msg", msg);
			//从当前页1开始逐页生成文件
			show_step("step_make");
			make(now_page);
		});
	} else {
		show_step("step_end");
	}
}

function make(page) {
	show_msg("step_make_msg", "正在创建第" + now_page + '页<img src="images/loading.gif" align="absmiddle" />');
	var url = "system.asp?rd="+Math.random()+"&handler=ajax&cmd=make&xmlpath="+xmlpath+"&xmlconfig="+xmlconfig+"&xmllist="+xmllist+"&page="+page;
	$.get(url, function(data){
		if(data != ""){
			if (data != "MakeComplete") {
				//继续下一轮make
				var page = parseInt(data);
				if(isNaN(page)) {
					remakeHd("当前页码错误！");
				} else {
					now_page = page
					now_page ++;
					make(now_page);
				}
			} else {
				show_msg("step_make_msg", "完成");
				show_step("step_end");
			}
		} else {
			show_msg("step_make_msg", "错误");
		}
	});
}
//
function show_step(step) {
	var obj = document.getElementById(step);
	obj.style.display = "block";
}
function show_msg(step, msg) {
	var obj = document.getElementById(step);
	obj.innerHTML = msg;
}

</script>
<%
'更新Application信息
clearApp()
end sub


sub database()
%>
<div>
  <input type="button" value="压缩和修复数据库" onClick="fixmdb(this);" />
  <strong id="fix_status"></strong></div>
<script type="text/javascript">
function fixmdb(o) {
	o.disabled = "disabled";
	show_status('<img src="images/loading.gif" align="absmiddle" />');
	$.get("system.asp?handler=ajax&cmd=fixmdb", function(data){
		if(data != ""){
			show_status(data);
		} 
		o.disabled = "";
	});
}
function show_status(status) {
	var obj = document.getElementById("fix_status");
	obj.innerHTML = status;
}
</script>
<%
end sub

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
      <td align="right">CMP系统统计(图片方式)：</td>
      <td><input name="site_count" type="text" id="site_count" value="<%=site_count%>" size="50" /></td>
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
		'开启： regsvr32 scrrun.dll  重启电脑后运行
		'关闭： regsvr32 /u scrrun.dll
	  %>
        <input name="xml_make" type="checkbox" id="xml_make" value="" disabled="disabled" />
        您的服务器不支持FSO，无法开启此功能
        <%else%>
        <input name="xml_make" type="checkbox" id="xml_make" value="1" <%if xml_make="1" then%>checked="checked"<%end if%> onClick="xmlmake(this);" />
        开启将减轻服务器负担(<strong>服务器必须支持FSO和文件可写</strong>)
        <%end if%>
        <div id="xmloption" <%if xml_make<>"1" then%>style="display:none;"<%end if%>>
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td>生成静态数据的文件夹名：
                <input name="xml_path" type="text" id="xml_path" value="<%=xml_path%>" />
                当前所占空间：<strong><%=getFolderSize(xml_path)%></strong></td>
            </tr>
            <tr>
              <td>用户id匹配配置文件的文件名：
                <input name="xml_config" type="text" id="xml_config" value="<%=xml_config%>" /></td>
            </tr>
            <tr>
              <td>用户id匹配列表文件的文件名：
                <input name="xml_list" type="text" id="xml_list" value="<%=xml_list%>" /></td>
            </tr>
            <%if xml_make="1" then%>
            <tr>
              <td><input type="button" value="手动重建所有静态数据文件" onClick="window.location='system.asp?action=remake';" /></td>
            </tr>
            <%end if%>
            <tr>
              <td><div style="color:#0000FF;">
                  <div>注：文件夹名请勿用同级目录下系统已存文件夹名称，如images,data,skins,plugins等，以防止重建时被一起删除</div>
                  <div>ID匹配文件名推荐用config.xml和list.xml，请勿用*.asp,*.asa等服务端程序后缀名，以防止恶意脚本执行</div>
                  <div>修改静态数据设置，所有用户静态数据将被重建或全部删除，且CMP调用地址将改变，请务必通知用户</div>
                  <div>请勿经常改动静态数据设置，尤其用户过多时，重建所有静态数据将耗费大量服务器资源和时间</div>
                </div></td>
            </tr>
          </table>
        </div></td>
    </tr>
    <tr>
      <td align="right">系统公告：<br />
        (支持html)</td>
      <td><textarea name="site_ad_news" cols="100" rows="5" style="width:98%;"><%=site_ad_news%></textarea></td>
    </tr>
    <tr>
      <td align="right">页顶广告：<br />
        (支持html)</td>
      <td><textarea name="site_ad_top" cols="100" rows="5" style="width:98%;"><%=site_ad_top%></textarea></td>
    </tr>
    <tr>
      <td align="right">页底广告：<br />
        (支持html)</td>
      <td><textarea name="site_ad_bottom" cols="100" rows="5" style="width:98%;"><%=site_ad_bottom%></textarea></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" />
        <a href="system.asp?action=update_config">刷新系统配置缓存</a></td>
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
		if(o.xml_path.value=="" || o.xml_path.value=="images" || o.xml_path.value=="data" || o.xml_path.value=="skins" || o.xml_path.value=="plugins" || !checkbadwords(o.xml_path.value, "./\\:*?<>\"|")){
			alert("生成静态数据的文件夹名不正确！");
			o.xml_path.select();
			return false;
		}
		if(o.xml_config.value=="" || !checkbadwords(o.xml_config.value, "/\\:*?<>\"|")){
			alert("用户id匹配配置文件的文件名不正确！");
			o.xml_config.select();
			return false;
		}
		if(o.xml_list.value=="" || !checkbadwords(o.xml_list.value, "/\\:*?<>\"|")){
			alert("用户id匹配列表文件的文件名不正确！");
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
    <td align="right">数据库路径：</td>
    <td><%=Server.MapPath(sitedb)%></td>
  </tr>
  <tr>
    <td align="right">数据库大小：</td>
    <td><%=getFileInfo(sitedb)(0)%></td>
  </tr>
  <tr>
    <td align="right">数据库优化：</td>
    <td><%database()%>
      推荐经常操作，可以有效地释放无效空间，加快访问速度</td>
  </tr>
  <tr>
    <td align="right">数据库备份：</td>
    <td>出于安全性考虑，请管理员用ftp直接在服务器复制或下载数据库文件进行备份</td>
  </tr>
</table>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th colspan="2" align="left">服务器信息：</th>
  </tr>
  <tr>
    <td align="right">本机IP：</td>
    <td><%=request.servervariables("remote_addr")%></td>
  </tr>
  <tr>
    <td align="right">服务器地址：</td>
    <td><%=Request.ServerVariables("SERVER_NAME")%> (IP:<%=Request.ServerVariables("LOCAL_ADDR")%>)</td>
  </tr>
  <tr>
    <td align="right">文件物理路径：</td>
    <td><%=server.mappath(Request.ServerVariables("SCRIPT_NAME"))%></td>
  </tr>
  <tr>
    <td align="right">是否支持FSO：</td>
    <td><%if CheckObjInstalled("Scripting.FileSystemObject")=false then%>
      否
      <%else%>
      是
      <%end if%></td>
  </tr>
  <tr>
    <td align="right">IIS信息：</td>
    <td><%=Request.ServerVariables("SERVER_SOFTWARE")%> 脚本:<%=ScriptEngine & "/"& ScriptEngineMajorVersion &"."&ScriptEngineMinorVersion&"."& ScriptEngineBuildVersion %> 超时:<%=Server.ScriptTimeout%> CPU:<%=Request.ServerVariables("NUMBER_OF_PROCESSORS")%> 系统:<%=Request.ServerVariables("OS")%></td>
  </tr>
  <tr>
    <td align="right" nowrap="nowrap">支持的文件类型：</td>
    <td><%=Request.ServerVariables("HTTP_Accept")%></td>
  </tr>
</table>
<%
end sub

sub update_config()
	clearApp()
	Response.Redirect("system.asp")
end sub

sub save_config()
	'cmp_path,site_name,site_url,site_qq,site_email,site_count,site_ads,user_reg,user_check,xml_make,xml_path,xml_config,xml_list
	cmp_path=Checkstr(Request.Form("cmp_path"))
	site_name=Checkstr(Request.Form("site_name"))
	site_url=Checkstr(Request.Form("site_url"))
	site_qq=Checkstr(Request.Form("site_qq"))
	site_email=Checkstr(Request.Form("site_email"))
	site_count=Checkstr(Request.Form("site_count"))
	site_ad_news=Checkstr(Request.Form("site_ad_news"))
	site_ad_top=Checkstr(Request.Form("site_ad_top"))
	site_ad_bottom=Checkstr(Request.Form("site_ad_bottom"))
	site_ads=site_ad_news &"{|}"& site_ad_top &"{|}"& site_ad_bottom
	user_reg=Checkstr(Request.Form("user_reg"))
	user_check=Checkstr(Request.Form("user_check"))
	'静态数据设置
	dim xmlmake,xmlpath,xmlconfig,xmllist
	xmlmake=Checkstr(Request.Form("xml_make"))
	xmlpath=Checkstr(Request.Form("xml_path"))
	xmlconfig=Checkstr(Request.Form("xml_config"))
	xmllist=Checkstr(Request.Form("xml_list"))
	'保存到数据库
  	sql = "Update cmp_config Set "
	sql = sql & "cmp_path='"&cmp_path&"',site_name='"&site_name&"',site_url='"&site_url&"',site_qq='"&site_qq&"',site_email='"&site_email&"',site_count='"&site_count&"',site_ads='"&site_ads&"',"
	sql = sql & "user_reg='"&user_reg&"',user_check='"&user_check&"',xml_make='"&xmlmake&"',"
	sql = sql & "xml_path='"&xmlpath&"',xml_config='"&xmlconfig&"',xml_list='"&xmllist&"',lasttime="&SqlNowString&""
	'response.Write(sql)
	conn.execute(sql)
	if xmlmake=xml_make and xmlpath=xml_path and xmlconfig=xml_config and xmllist=xml_list then
		'更新Application信息
		clearApp()
		SucMsg="修改成功！"
		Cenfun_suc("system.asp?action=config")
	else
		call reMakeData(xmlmake, xmlpath, xmlconfig, xmllist)
	end if
end sub


sub user()
'操作处理
dim idlist
idlist = Checkstr(Request.QueryString("idlist"))
if idlist <> "" then
	dim deal
	deal=Checkstr(Request.QueryString("deal"))
	select case deal
	case "del"
		conn.execute("delete from cmp_user where id in ("&idlist&")")
	case "lock"
		conn.execute("update cmp_user set userstatus=1 where id in ("&idlist&")")
	case "enable"
		conn.execute("update cmp_user set userstatus=5 where id in ("&idlist&")")
	case else
	end select
	'删除idlist的静态数据
	if xml_make="1" and deal<>"enable" then
		dim uid
		idlist = Split(idlist, ",")
		For Each uid in idlist
			'删除用户配置和列表文件
			delFile(xml_path & "/" & trim(uid) & xml_config)
			delFile(xml_path & "/" & trim(uid) & xml_list)
		Next
	end if
	SucMsg="操作完成！"
	Cenfun_suc(Request.QueryString("referer"))
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
        <option value="5" <%if userstatus="5" then%>selected="selected"<%end if%>>普通用户</option>
        <option value="8" <%if userstatus="8" then%>selected="selected"<%end if%>>管理员</option>
      </select></td>
  </tr>
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form>
          <%
'查询串
sql = "select id,username,userstatus,lasttime,hits,logins,list,email,qq,cmp_name from cmp_user where "
if username <> "" then
	sql = sql & " InStr(1,LCase(username),LCase('"&username&"'),0)<>0 and "
end if
if userstatus <> "" then
	if IsNumeric(userstatus) then
		if userstatus="8" then
			sql = sql & " userstatus>="&userstatus&" and "
		else
			sql = sql & " userstatus="&userstatus&" and "
		end if
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
	case "hits"
		sql = sql & " order by hits " & order
	case "logins"
		sql = sql & " order by logins " & order
	case "qq"
		sql = sql & " order by len(qq) " & order & " ,qq " & order
	case "lasttime"
		sql = sql & " order by lasttime " & order
	case "list"
		sql = sql & " order by len(list) " & order
	case "cmp_name"
		sql = sql & " order by cmp_name " & order
	case else
		sql = sql & " order by id desc"
		by = ""
		order = ""
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
            <th><a href="javascript:orderby('hits');" title="点击按其排序">查看</a></th>
            <th><a href="javascript:orderby('logins');" title="点击按其排序">登录</a></th>
            <th><a href="javascript:orderby('list');" title="点击按其排序">音乐量</a></th>
            <th><a href="javascript:orderby('qq');" title="点击按其排序">QQ</a></th>
            <th><a href="javascript:orderby('cmp_name');" title="点击按其排序">播放器名</a></th>
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
		case 8
			role = "<strong style='color:#ff0000'>管理员</strong>"
		case 9
			role = "<strong style='color:#0000ff'>系统管理员</strong>"
		case else
			role = "未定义"
		end select
		%>
          <tr align="center" onMouseOver="highlight(this,'#F9F9F9');">
            <td><%if ustatus<>9 then%>
              <input type="checkbox" name="idlist" id="idlist" value="<%=rs("id")%>" />
              <%end if%></td>
            <td><%=role%></td>
            <td><%=rs("id")%></td>
            <td><a href="system.asp?action=edituser&amp;id=<%=rs("id")%>" title="点击查看和编辑详细资料"><%=rs("username")%></a></td>
            <td title="<%=rs("lasttime")%>"><%=FormatDateTime(rs("lasttime"),2)%></td>
            <td><%=rs("hits")%></td>
            <td><%=rs("logins")%></td>
            <td><%=Len(Trim(rs("list")))%></td>
            <td><a href="<%=getQqUrl(rs("qq"))%>" target="_blank"><%=Left(rs("qq"),10)%></a></td>
            <td><a href="<%=getCmpUrl(rs("id"))%>" target="_blank" title="<%=rs("cmp_name")%>"><%=Left(rs("cmp_name"),12)%></a></td>
            <td><a href="system.asp?action=edituser&amp;id=<%=rs("id")%>">操作</a></td>
          </tr>
          <%rs.MoveNext%>
          <%PageC=PageC+1%>
          <%loop%>
          <tr>
            <td colspan="12"><div style="float:right;padding-top:5px;"><%=showpage("zh",1,"system.asp?action=user&username="&username&"&userstatus="&userstatus&"&order="&order&"&by="&by&"",rs_nums,MaxPerPage,true,true,"个",CurrentPage)%></div>
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
				window.location = "system.asp?action=user&deal=del&idlist="+id_list+"&referer="+encodeURIComponent(window.location);
			}else if(str == "锁定"){
				window.location = "system.asp?action=user&deal=lock&idlist="+id_list+"&referer="+encodeURIComponent(window.location);
			}else if(str == "激活"){
				window.location = "system.asp?action=user&deal=enable&idlist="+id_list+"&referer="+encodeURIComponent(window.location);
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
	dim userstatus
	userstatus = rs("userstatus")
	dim cmpurl
	cmpurl = getCmpUrl(rs("id"))
	dim strConfig,strList
	strConfig = UnCheckStr(rs("config"))
	strList = UnCheckStr(rs("list"))
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
      <td align="right">用户名：</td>
      <td><%=rs("username")%></td>
    </tr>
    <%if userstatus <> 9 then%>
    <tr>
      <td align="right">状态：</td>
      <td><select name="userstatus">
          <option value="0" <%if userstatus=0 then%>selected="selected"<%end if%>>未激活</option>
          <option value="1" <%if userstatus=1 then%>selected="selected"<%end if%>>被锁定</option>
          <option value="5" <%if userstatus=5 then%>selected="selected"<%end if%>>普通用户</option>
          <option value="8" <%if userstatus=8 then%>selected="selected"<%end if%>>管理员</option>
        </select></td>
    </tr>
    <tr>
      <td align="right">密码：</td>
      <td><input name="password" type="password" id="password" size="30" />
        一般用于帮用户重置密码，不修改请留空。</td>
    </tr>
    <%else%>
    <tr>
      <td align="right">状态：</td>
      <td><strong>系统管理员</strong></td>
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
      <td align="right">不公开到用户列表：</td>
      <td><input name="setinfo" type="checkbox" value="1" <%if rs("setinfo")=1 then%>checked="checked"<%end if%> /></td>
    </tr>
    <tr>
      <td align="right">播放器地址：</td>
      <td><a href="<%=cmpurl%>" target="_blank"><%=cmpurl%></a></td>
    </tr>
    <tr>
      <td align="right">播放器配置：</td>
      <td><textarea name="config" rows="10" id="config" style="width:99%;"><%=strConfig%></textarea></td>
    </tr>
    <tr>
      <td align="right">播放器列表：</td>
      <td><textarea name="list" rows="10" id="list" style="width:99%;"><%=strList%></textarea></td>
    </tr>
    <tr>
      <td width="20%">&nbsp;</td>
      <td width="80%"><input name="submit" type="submit" value="修改" style="width:50px;" />
        <input name="" type="button" value="取消" style="width:50px;" onClick="window.location='<%=referer%>';" /></td>
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
	if("<%=userstatus%>" != "8" && o.userstatus.value=="8"){
		if(!confirm("确定将此用户升级为管理员吗？")){
			o.reset();
			return false;
		}
	}
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
	if (!check_config(o)) {
		o.config.focus();
		return false;
	}
	if (!check_list(o)) {
		o.list.focus();
		return false;
	}
	return true;
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
end if
end sub

sub saveuser()
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		'修改用户信息
		sql = "select username,config,list from cmp_user where id="&id
		set rs = conn.execute(sql)
		if not rs.eof then
			dim password,userstatus,logins,hits,email,qq,cmp_name,cmp_url,setinfo,config,list
			if Request.Form("password")<>"" then
				password=md5(Request.Form("password")+rs("username"),16)
				conn.execute("update cmp_user set [password]='"&password&"' where username='"&rs("username")&"'")
			end if
			userstatus=Checkstr(Request.Form("userstatus"))
			logins=Checkstr(Request.Form("logins"))
			hits=Checkstr(Request.Form("hits"))
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
			list = CheckStr(request.Form("list"))
			'生成静态文件
			if xml_make="1" then
				if rs("config")<>config then
					call makeFile(xml_path & "/" & id & xml_config, UnCheckStr(config))
				end if
				if rs("list")<>list then
					call makeFile(xml_path & "/" & id & xml_list, UnCheckStr(list))
				end if
			end if
			'保存至数据库
			sql = "update cmp_user set logins="&logins&",hits="&hits&","
			sql = sql & "email='"&email&"',qq='"&qq&"',cmp_name='"&cmp_name&"',cmp_url='"&cmp_url&"',"
			'用户组状态
			if userstatus<>"" then
				if IsNumeric(userstatus) then
					if userstatus<>9 then
						sql = sql & "userstatus="&userstatus&","
					end if
				end if
			end if
			sql = sql & "setinfo="&setinfo&",config='"&config&"',list='"&list&"' where username='"&rs("username")&"' "
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
dim deal
deal = Request.QueryString("deal")
if deal<>"" then
	dim id,title,src
	select case deal
		case "add"
			title = Checkstr(Request.Form("skin_title"))
			src = Checkstr(Request.Form("skin_src"))
			sql = "insert into cmp_skins "
			sql = sql & "(title,src) values("
			sql = sql & "'"&title&"','"&src&"')"
			conn.execute(sql)
		case "del"
			id = Checkstr(Request.QueryString("id"))
			conn.execute("delete from cmp_skins where id in ("&id&")")
		case "edit"
			id = Checkstr(Request.QueryString("id"))
			title = Checkstr(Request.Form("skin_title"))
			src = Checkstr(Request.Form("skin_src"))
			sql = "update cmp_skins set "
			sql = sql & "title='"&title&"',src='"&src&"' "
			sql = sql & "where id="&id&" "
			conn.execute(sql)
		case else
	end select
	response.Redirect("system.asp?action=skins")
else
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">系统皮肤管理</th>
  </tr>
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form action="system.asp?action=skins&amp;deal=add" method="post" onSubmit="return check(this);">
          <tr align="center">
            <td><input name="skin_title" type="text" maxlength="50" /></td>
            <td><input name="skin_src" type="text" maxlength="200" /></td>
            <td colspan="3"><input name="add_submit" type="submit" value="添加皮肤" /></td>
          </tr>
        </form>
        <tr>
          <th>名称</th>
          <th>路径</th>
          <th colspan="3">操作</th>
        </tr>
        <%
		'取得用户ID
		dim userid,cmp_show_url
		userid = Session(CookieName & "_userid")
		cmp_show_url = getCmpUrl(userid)
		'所有皮肤
		sql = "select * from cmp_skins order by id desc"
		set rs = conn.execute(sql)
		Do Until rs.EOF
		%>
        <form action="system.asp?action=skins&amp;deal=edit&amp;id=<%=rs("id")%>" method="post" onSubmit="return check(this);">
          <tr align="center" onMouseOver="highlight(this,'#F9F9F9');">
            <td><input name="skin_title" type="text" value="<%=trim(rs("title"))%>" maxlength="50" /></td>
            <td><input name="skin_src" type="text" value="<%=trim(rs("src"))%>" maxlength="200" /></td>
            <td><input name="edit_submit" type="submit" value="修改" /></td>
            <td><input name="show_submit" type="button" value="预览" onClick="skin_show('<%=cmp_show_url & "&skin=" & rs("src")%>');" /></td>
            <td><input name="del_submit" type="button" value="删除" onClick="skin_del('<%=rs("id")%>');" /></td>
          </tr>
        </form>
        <%
		rs.MoveNext
		loop
		rs.close
		set rs = nothing
		%>
      </table></td>
  </tr>
  <tr><td>注意，如果所有皮肤都加载错误，可能是因为空间不支持zip文件的访问，请尝试将皮肤包文件的后缀zip改为swf</td></tr>
</table>
<script type="text/javascript">
function skin_del(id){
	if(confirm("确定要【删除】此皮肤吗？")){
		window.location = "system.asp?action=skins&deal=del&id="+id;
	}
}
function skin_show(url){
	if (url) {
		window.open(url);
	}
}
function check(o){
	if(o.skin_title.value==""){
		alert("皮肤名称不能为空！");
		o.skin_title.focus();
		return false;
	}
	if(o.skin_src.value==""){
		alert("皮肤路径不能为空！");
		o.skin_src.focus();
		return false;
	}
	return true;
}
</script>
<%
end if
end sub

sub plugins()
dim deal
deal = Request.QueryString("deal")
if deal<>"" then
	dim id,title,src
	select case deal
		case "add"
			title = Checkstr(Request.Form("plugin_title"))
			src = Checkstr(Request.Form("plugin_src"))
			sql = "insert into cmp_plugins "
			sql = sql & "(title,src) values("
			sql = sql & "'"&title&"','"&src&"')"
			conn.execute(sql)
		case "del"
			id = Checkstr(Request.QueryString("id"))
			conn.execute("delete from cmp_plugins where id in ("&id&")")
		case "edit"
			id = Checkstr(Request.QueryString("id"))
			title = Checkstr(Request.Form("plugin_title"))
			src = Checkstr(Request.Form("plugin_src"))
			conn.execute("update cmp_plugins set title='"&title&"',src='"&src&"' where id="&id&" ")
		case else
	end select
	response.Redirect("system.asp?action=plugins")
else
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">系统插件管理</th>
  </tr>
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form action="system.asp?action=plugins&amp;deal=add" method="post" onSubmit="return check(this);">
          <tr align="center">
            <td><input name="plugin_title" type="text" maxlength="50" /></td>
            <td><input name="plugin_src" type="text" maxlength="200" /></td>
            <td colspan="3"><input name="add_submit" type="submit" value="添加插件" /></td>
          </tr>
        </form>
        <tr>
          <th>名称</th>
          <th>路径</th>
          <th colspan="3">操作</th>
        </tr>
        <%
		'所有插件
		sql = "select id,title,src from cmp_plugins order by id desc"
		set rs = conn.execute(sql)
		Do Until rs.EOF
		%>
        <form action="system.asp?action=plugins&amp;deal=edit&amp;id=<%=rs("id")%>" method="post" onSubmit="return check(this);">
          <tr align="center" onMouseOver="highlight(this,'#F9F9F9');">
            <td><input name="plugin_title" type="text" value="<%=rs("title")%>" maxlength="50" /></td>
            <td><input name="plugin_src" type="text" value="<%=rs("src")%>" maxlength="200" /></td>
            <td><input name="edit_submit" type="submit" value="修改" /></td>
            <td><input name="show_submit" type="button" value="预览" onClick="plugin_show('<%=rs("src")%>');" /></td>
            <td><input name="del_submit" type="button" value="删除" onClick="plugin_del('<%=rs("id")%>');" /></td>
          </tr>
        </form>
        <%
		rs.MoveNext
		loop
		rs.close
		set rs = nothing
		%>
      </table></td>
  </tr>
</table>
<script type="text/javascript">
function plugin_del(id){
	if(confirm("确定要【删除】此插件吗？")){
		window.location = "system.asp?action=plugins&deal=del&id="+id;
	}
}
function plugin_show(url){
	if (url) {
		window.open(url);
	}
}
function check(o){
	if(o.plugin_title.value==""){
		alert("插件名称不能为空！");
		o.plugin_title.focus();
		return false;
	}
	if(o.plugin_src.value==""){
		alert("插件路径不能为空！");
		o.plugin_src.focus();
		return false;
	}
	return true;
}
</script>
<%
end if
end sub


%>
