<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
site_title = "留言簿"
header()
menu()
Select Case Request.QueryString("action")
	Case "top_up"
		set_top(1)
	Case "top_down"
		set_top(0)
	Case "edit_reply"
		edit_reply()
	Case "show_post"
		show_post(true)	
	Case "del_post"
		del_post()
	Case "clear_post"
		clear_post()
	Case "save_post"
		save_post()
	Case Else
		main()
End Select
footer()

sub main()
%>
<div class="gbox">
  <div style="margin:5px 5px;"><span>( <a href="javascript:sha(true);">展开所有内容</a> | <a href="javascript:sha(false);">收起所有内容</a> )</span>
    <%if founduser then%>
    <span style="margin-left:10px;"><a href="gbook.asp?action=show_post"><strong>立刻发表留言 » </strong></a></span>
    <%end if%>
  </div>
</div>
<%
'查询串
'id,user_id,user_ip,title,content,reply,istop,hidden,addtime,replytime
sql = "select g.id,g.user_id,g.user_ip,g.title,g.content,g.reply,g.istop,g.hidden,g.addtime,g.replytime,u.cmp_name from cmp_gbook g inner join cmp_user u on g.user_id=u.id order by istop desc, addtime desc"
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
	MaxPerPage=20
set rs=Server.CreateObject("ADODB.RecordSet")
rs.Open sql,conn,1,1
IF not rs.EOF Then
	rs.PageSize=MaxPerPage
	rs.AbsolutePage=CurrentPage
	Dim rs_nums
	rs_nums=rs.RecordCount
	%>
<%Do Until rs.EOF OR PageC=rs.PageSize%>
<div class="gbox">
  <div class="gtitle" onmouseover="highlight(this,'#F9F9F9');" onclick="shc(<%=rs("id")%>);"><strong><%=HTMLEncode(rs("title"))%></strong>[<a href="userlist.asp?user_id=<%=rs("user_id")%>" target="_blank"><%=rs("cmp_name")%></a>]<span><%=rs("addtime")%>
    <%if foundadmin then%>
    &nbsp;&nbsp;IP:<%=rs("user_ip")%>
    <%end if%>
    </span>
    <%if rs("istop")=1 then%>
    【置顶】
    <%end if%>
  </div>
  <div class="gcontent" id="post<%=rs("id")%>">
    <%
  	if rs("hidden")=0 or foundadmin or rs("user_id")=Session(CookieName & "_userid") then
	%>
    <%=HTMLEncode(rs("content"))%>
    <%if rs("reply")<>"" then%>
    <div class="greply">
      <div>管理员回复：<span><%=rs("replytime")%></span></div>
      <div style="padding:5px 0px;"><%=HTMLEncode(rs("reply"))%></div>
    </div>
    <%end if%>
    <%if foundadmin then%>
    <textarea id="reply<%=rs("id")%>" style="display:none;"><%=XMLEncode(UnCheckStr(rs("reply")))%></textarea>
    <div id="replyform<%=rs("id")%>"></div>
    <%end if%>
    <%
	else
		response.Write("此内容设置了隐藏，仅管理员可见。")
  	end if
    %>
    <%if founduser then%>
    <%if foundadmin or rs("user_id")=Session(CookieName & "_userid") then%>
    <div class="gadmin"><a href="javascript:delpost(<%=rs("id")%>)">删除</a> | <a href="gbook.asp?action=show_post&deal=edit&id=<%=rs("id")%>">编辑</a>
      <%if foundadmin then%>
      <%if rs("reply")<>"" then%>
      | <a href="javascript:replypost(<%=rs("id")%>)">编辑回复</a>
      <%else%>
      | <a href="javascript:replypost(<%=rs("id")%>)">回复</a>
      <%end if%>
      <%if rs("istop")=1 then%>
      | <a href="gbook.asp?action=top_down&id=<%=rs("id")%>">取消置顶</a>
      <%else%>
      | <a href="gbook.asp?action=top_up&id=<%=rs("id")%>">置顶</a>
      <%end if%>
      <%end if%>
    </div>
    <%end if%>
    <%end if%>
  </div>
</div>
<%rs.MoveNext%>
<%PageC=PageC+1%>
<%loop%>
<%if rs_nums>MaxPerPage then%>
<div class="gbox">
  <div style="padding:5px 5px;"><%=showpage("zh",1,"gbook.asp",rs_nums,MaxPerPage,true,true,"条",CurrentPage)%></div>
</div>
<%
end if
else
%>
<div class="gbox">
  <div style="margin:5px 5px;"><span style="color:#FF0000;">没有找到任何相关记录</span></div>
</div>
<%
end if
rs.Close
Set rs=Nothing
'发表留言
if founduser then
	show_post(false) 
end if
'管理选项
if foundadmin then
	show_admin()
end if	
%>
<script type="text/javascript">
function shc(id) {
	var o = document.getElementById("post"+id);
	if (o.style.display == "none") {
		o.style.display = "";
	} else {
		o.style.display = "none";
	}
}
function sha(flag) {
	var divs = document.getElementsByTagName("div");
	for (var i = 0; i < divs.length; i ++) {
		var div = divs[i];
		if (div.className == "gcontent") {
			if (flag) {
				div.style.display = "";
			} else {
				div.style.display = "none";
			}
		}
	}
}
<%if founduser then%>
function delpost(id) {
	if (confirm("确定要删除吗？")) {
		window.location = "gbook.asp?action=del_post&id="+id+"&referer="+encodeURIComponent(window.location);
	}
}
<%end if%>
<%if foundadmin then%>
function replypost(id) {
	var replyform = document.getElementById("replyform"+id);
	replyform.style.display = "";
	var html = '';
	html +='<form action="gbook.asp?action=edit_reply&id='+id+'" method="post">';
  	html +='<div><textarea name="reply" id="edit_replyform'+id+'" rows="10" style="width:99%;"></textarea></div>';
  	html +='<div>';
	html +='<input type="submit" value="提交" /> ';
	html +='<input type="reset" value="取消" onclick="cannelreply('+id+');" />';
	html +='</div></form>';
	replyform.innerHTML = html;
	//
	var reply = document.getElementById("reply"+id);
	if (reply) {
		var edit_replyform = document.getElementById("edit_replyform"+id);
		edit_replyform.value = reply.value;
	}
}
function cannelreply(id) {
	var replyform = document.getElementById("replyform"+id);
	replyform.style.display = "none";
}
<%end if%>
</script>
<%
end sub

sub show_admin()
%>
<div class="gbox">
  <div style="margin:5px 5px;"><strong>批量管理：</strong>清除
    <input id="cleardays" type="text" value="60" size="3" maxlength="5" />
    天以前的所有留言
    <input type="button" value="提交" onclick="clearByDay();" />
  </div>
</div>
<script type="text/javascript">
function clearByDay() {
	var cleardays = document.getElementById("cleardays");
	var days = cleardays.value;
	if (days && !isNaN(days)) {
		if (confirm("确定要清除"+days+"天以前的所有留言？")) {
			window.location = "gbook.asp?action=clear_post&days="+days;
		}
	} else {
		alert("请填写正确清除期限！");
		cleardays.focus();
	}
}
</script>
<%
end sub
sub show_post(flag)
if founduser then
	dim deal,formtitle,formbt,user_id,id,title,content,hidden
	deal=Request.QueryString("deal")
	if deal="edit" then
		deal="edit"
		formtitle="编辑"
		formbt="修改"
		id=Checkstr(Request.QueryString("id"))
		if id<>"" then
			if isNumeric(id) then
				set rs=conn.execute("select user_id,title,content,hidden from cmp_gbook where id="&id&" ")
				if not rs.eof then
					user_id=rs("user_id")
					if foundadmin or user_id=Session(CookieName & "_userid") then
						title=XMLEncode(UnCheckStr(rs("title")))
						content=XMLEncode(UnCheckStr(rs("content")))
						hidden=rs("hidden")
					else
						ErrMsg="没有操作权限！"
					end if
				else
					ErrMsg="未找到记录！"
				end if
				rs.close
				set rs=nothing
			else
				ErrMsg="参数错误！"
			end if
		else
			ErrMsg="参数错误！"
		end if
	else
		deal="add"
		formtitle="发表"
		formbt="提交"
		title=""
		content=""
		hidden=0
	end if
else
	ErrMsg="没有操作权限！"
end if

if ErrMsg<>"" then
	cenfun_error()
else
%>
<%if flag then%>
<div class="gbox">
  <div style="padding:5px 5px;">
    <input name="bt_back" type="button" onclick="history.back();" value="&lt;&lt;返回" />
  </div>
</div>
<%else%>
<a name="newpost"></a>
<%end if%>
<div class="gbox">
  <table border="0" cellspacing="1" cellpadding="2" width="100%">
    <form action="gbook.asp?action=save_post&deal=<%=deal%>" method="post" onSubmit="return check_post(this);">
      <tr>
        <td>&nbsp;</td>
        <td height="24"><strong><%=formtitle%>留言</strong>
          <%if deal="edit" then%>
          <input name="id" type="hidden" value="<%=id%>" />
          <%end if%></td>
      </tr>
      <tr>
        <td align="right" nowrap="nowrap">标题：</td>
        <td><input name="title" type="text" size="45" maxlength="200" value="<%=title%>" /></td>
      </tr>
      <tr>
        <td align="right">内容：</td>
        <td><textarea name="content" cols="45" rows="10" style="width:98%;"><%=content%></textarea></td>
      </tr>
      <tr>
        <td align="right">隐藏：</td>
        <td><input type="checkbox" name="hidden" value="1" <%if hidden=1 then%>checked="checked"<%end if%> />
          (仅管理员可见) </td>
      </tr>
      <tr>
        <td align="right">&nbsp;</td>
        <td><input type="submit" name="submitbutton" value="<%=formbt%>" /></td>
      </tr>
    </form>
  </table>
</div>
<script type="text/javascript">
function check_post(o){
	if(o.title.value.length < 3){
		alert("标题长度不能小于3！");
		o.title.focus();
		return false;
	}
	if(o.content.value.length < 10){
		alert("内容长度不能小于10！");
		o.content.focus();
		return false;
	}
	if(o.content.value.length > 10000){
		alert("内容长度不能大于10000！");
		o.content.focus();
		return false;
	}
	return true;
}
</script>
<%
end if
end sub

sub del_post()
dim id,referer
id=Checkstr(Request.QueryString("id"))
referer=Request.QueryString("referer")
if referer="" then
	referer="gbook.asp"
end if
if foundadmin then
	'管理员直接删除
	conn.execute("delete from cmp_gbook where id in ("&id&")")
elseif founduser then
	conn.execute("delete from cmp_gbook where id in ("&id&") and user_id="&Session(CookieName & "_userid"))
end if
response.Redirect(referer)
end sub

sub clear_post()
if foundadmin then
	dim days
	days=Checkstr(Request.QueryString("days"))
	if days<>"" then
		if isNumeric(days) then
			conn.execute("delete from cmp_gbook where DateDiff('d', addtime, "&SqlNowString&")>=" & days)
			response.Redirect("gbook.asp")
		end if
	end if
else
	ErrMsg="没有操作权限！"
	cenfun_error()
end if
end sub


sub set_top(flag)
if foundadmin then
	dim id
	id=Checkstr(Request.QueryString("id"))
	conn.execute("update cmp_gbook set istop="&flag&" where id in ("&id&")")
	response.Redirect("gbook.asp")
else
	ErrMsg="没有操作权限！"
	cenfun_error()
end if
end sub


sub edit_reply()
if foundadmin then
	dim id,reply
	id=Checkstr(Request.QueryString("id"))
	reply=Checkstr(Request.Form("reply"))
	if id<>"" then
		if isNumeric(id) then
			conn.execute("update cmp_gbook set reply='"&reply&"',replytime="&SqlNowString&" where id="&id&" ")
			response.Redirect(Request.ServerVariables("HTTP_REFERER"))
		end if
	end if
else
	ErrMsg="没有操作权限！"
	cenfun_error()
end if
end sub


sub save_post()
'id,user_id,user_ip,title,content,reply,istop,hidden,addtime,replytime
'用户已经登录
if founduser then
	dim deal,id,title,content,hidden,referer
	referer="gbook.asp"
	deal=Request.QueryString("deal")
	title=CheckStr(Request.Form("title"))
	content=CheckStr(Request.Form("content"))
	hidden=Request.Form("hidden")
	if hidden="" then
		hidden=0
	else
		hidden=1
	end if
	if deal="edit" then
		id=Checkstr(Request.Form("id"))
		if foundadmin then
			conn.execute("update cmp_gbook set title='"&title&"',content='"&content&"',hidden="&hidden&" where id="&id&" ")
		elseif founduser then
			conn.execute("update cmp_gbook set title='"&title&"',content='"&content&"',hidden="&hidden&" where id="&id&" and user_id="&Session(CookieName & "_userid"))
		end if
		SucMsg = "编辑留言完成！"
		cenfun_suc(referer)
	else
		if Request.Cookies(CookieName)("posttime")<>empty then
 	   		if DateDiff("s",Request.Cookies(CookieName)("posttime"),SystemTime) < 60 then
	    		ErrMsg="请不要在60秒内重复提交"
 	   		end if
		end if
		if ErrMsg<>"" then
			cenfun_error()
		else
			dim user_id
			user_id=Session(CookieName & "_userid")
			sql = "insert into cmp_gbook "
			sql = sql & "(user_id,user_ip,title,content,hidden,addtime) values("
			sql = sql & ""&user_id&",'"&UserTrueIP&"','"&title&"','"&content&"',"&hidden&","&SqlNowString&")"
			conn.execute(sql)
			SucMsg = "发表留言成功！"
			cenfun_suc(referer)
		end if
		'保存提交时间
		Response.Cookies(CookieName)("posttime")=SystemTime
	end if
else
	ErrMsg="没有操作权限！"
	cenfun_error()
end if
end sub

%>
