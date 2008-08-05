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
Case Else
	config()
End Select
footer()


sub config()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <form action="system.asp?action=save_config" method="post" onsubmit="return check(this);">
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
      <td align="right">系统统计(图片方式)：</td>
      <td><input name="site_count" type="text" id="site_count" value="<%=site_count%>" size="50" /></td>
    </tr>
    <tr>
      <td align="right">系统公告：<br />
        (支持html)</td>
      <td><textarea name="site_ads" cols="50" rows="8" id="site_ads"><%=site_ads%></textarea></td>
    </tr>
    <tr>
      <td align="right">是否开启用户注册：</td>
      <td align="left"><input name="user_reg" type="checkbox" id="user_reg" value="1" <%if user_reg="1" then%>checked="checked"<%end if%> /></td>
    </tr>
    <tr>
      <td align="right">用户注册是否需要审核：</td>
      <td align="left"><input name="user_check" type="checkbox" id="user_check" value="1" <%if user_check="1" then%>checked="checked"<%end if%> /></td>
    </tr>
    <tr>
      <td align="right" valign="top">是否生成静态XML数据文件：</td>
      <td align="left"><input name="xml_make" type="checkbox" id="xml_make" value="1" <%if xml_make="1" then%>checked="checked"<%end if%> onclick="xmlmake(this);" />
        开启将减轻服务器负担，并增加一种更稳定的调用方式。
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
        </div></td>
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
end sub


sub savepass()
	Dim UserName,ip
	Dim PassWord,PassWord1
	UserName=Replace(Request("username"),"'","")
	PassWord=md5(request("password"),16)
	PassWord1=md5(request("password1"),16)
	ip=UserTrueIP
	set rs=conn.Execute("select * from cmp_admin where password='"&PassWord&"'")
	if rs.eof then
		rs.close
		set rs=nothing
		Errmsg=Errmsg&"<li>原密码不正确,修改失败！"
		cenfun_error()
    	response.End
		Exit Sub
	else
		rs.close
		set rs=nothing
		'Response.write PassWord1
		conn.Execute("Update cmp_admin Set username='"&UserName&"',[password]='"&password1&"',Lasttime="&SqlNowString&",LastIP='"&ip&"' ")
		Session(CookieName & "_UserName")=UserName
		'session超时时间
		Session.Timeout=45
		SucMsg=SucMsg&"<li>修改密码成功！"
		Cenfun_suc("?")
	end if	
end sub
%>
