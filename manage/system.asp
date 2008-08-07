<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<!--#include file="md5.asp"-->
<%
'检测管理员是否登录
If Session(CookieName & "_username")="" or Session(CookieName & "_admin")="" Then
	response.Redirect("index.asp")
end if
'//////////////////////////////
header()
menu()
Select Case Request.QueryString("action")
Case "config"
	config()
Case "save_config"
	save_config()
Case "user"
	user()
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


sub config()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form action="system.asp?action=save_config" method="post" onSubmit="return check(this);">
    <tr>
      <td align="right">CMP地址：</td>
      <td><input name="cmp_path" type="text" id="cmp_path" value="<%=cmp_path%>" size="50" /></td>
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
      <td align="right">默认统计(图片方式)：</td>
      <td><input name="site_count" type="text" id="site_count" value="<%=site_count%>" size="50" /></td>
    </tr>
    <tr>
      <td align="right">系统公告：<br />
        (支持html)</td>
      <td><textarea name="site_ads" cols="50" rows="8" id="site_ads"><%=site_ads%></textarea></td>
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
      <td align="left"><input name="xml_make" type="checkbox" id="xml_make" value="1" <%if xml_make="1" then%>checked="checked"<%end if%> onClick="xmlmake(this);" />
        开启将减轻服务器负担，服务器必须支持FSO写文件
        <div id="xmloption" <%if xml_make<>"1" then%>style="display:none;"<%end if%>>
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td>生成文件的目录：</td>
              <td><input name="xml_path" type="text" id="xml_path" value="<%=xml_path%>" /></td>
            </tr>
            <tr>
              <td>模板配置文件名：</td>
              <td><input name="xml_config" type="text" id="xml_config" value="<%=xml_config%>" /></td>
            </tr>
            <tr>
              <td>模板列表文件名：</td>
              <td><input name="xml_list" type="text" id="xml_list" value="<%=xml_list%>" /></td>
            </tr>
          </table>
        </div>
        <div>修改后所有用户静态调用地址将改变，请务必通知</div></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><input name="submit" type="submit" value="修改" style="width:50px;" /></td>
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
		if(o.xml_config.value == o.xml_list.value){
			alert("模板配置和列表的名称不能相同！");
			o.xml_config.focus();
			return false;
		}
	}
	return true;
}
</script>
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
	xml_make=Request.Form("xml_make")
	xml_path=Checkstr(Request.Form("xml_path"))
	xml_config=Checkstr(Request.Form("xml_config"))
	xml_list=Checkstr(Request.Form("xml_list"))
  	sql = "Update cmp_config Set "
	sql = sql & "cmp_path='"&cmp_path&"',site_name='"&site_name&"',site_url='"&site_url&"',site_qq='"&site_qq&"',site_email='"&site_email&"',site_count='"&site_count&"',site_ads='"&site_ads&"',"
	sql = sql & "user_reg='"&user_reg&"',user_check='"&user_check&"',xml_make='"&xml_make&"',"
	sql = sql & "xml_path='"&xml_path&"',xml_config='"&xml_config&"',xml_list='"&xml_list&"',lasttime="&SqlNowString&""
	'response.Write(sql)
	conn.execute(sql)
	SucMsg=SucMsg&"修改成功！"
	Cenfun_suc("system.asp?action=config")
	'更新Application信息
	Application.Lock
	Application(CookieName&"_Arr_system_info")=""
	Application.UnLock
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
      </span><a href="system.asp?action=user" class="headlink">所有用户</a> | <a href="system.asp?action=user&userstatus=0" class="headlink">未激活用户</a> </td>
  </tr>
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form>
          <%
'查询串
sql = "select id,username,userstatus,email,qq,lasttime from cmp_user where "
if username <> "" then
	sql = sql & " username like '%"&username&"%' and "
end if
if userstatus <> "" then
	sql = sql & " userstatus="&userstatus&" and "
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
            <th><a href="javascript:orderby('userstatus');">状态</a></th>
            <th><a href="javascript:orderby('id');">ID</a></th>
            <th><a href="javascript:orderby('username');">用户名</a></th>
            <th><a href="javascript:orderby('lasttime');">最后登录</a></th>
            <th>Email</th>
            <th>QQ</th>
            <th>CMP</th>
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
          <tr align="center" onMouseOver="highlight(this,'#FbFbFb','#ffffff');">
            <td><%if ustatus<>9 then%>
              <input type="checkbox" name="idlist" id="idlist" value="<%=rs("id")%>" />
              <%end if%></td>
            <td><%=role%></td>
            <td><%=rs("id")%></td>
            <td><%=rs("username")%></td>
            <td><%=FormatDateTime(rs("lasttime"),2)%></td>
            <td><%=rs("email")%></td>
            <td><%=rs("qq")%></td>
            <td><a href="<%=cmp_path%>?url=<%=geturl(rs("id"))%>" target="_blank">查看</a></td>
            <td><a href="system.asp?action=edituser&amp;id=">详情编辑</a></td>
          </tr>
          <%rs.MoveNext%>
          <%PageC=PageC+1%>
          <%loop%>
          <tr>
            <td colspan="11"><div style="float:right;padding-top:5px;"><%=showpage("zh",1,"system.asp?action=user&username="&username&"&userstatus="&userstatus&"&order="&order&"&by="&by&"",rs_nums,MaxPerPage,true,true,"个",CurrentPage)%></div>
              <div style="padding:5px 5px;">
                <input type="button" value="删除" style="width:50px;" onClick="dealuser(this);" />
                <input type="button" value="锁定" style="width:50px;" onClick="dealuser(this);" />
                <input type="button" value="激活" style="width:50px;" onClick="dealuser(this);" />
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

sub saveuser()

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
