<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
header()
menu()
Select Case Request.QueryString("action")
	Case "save_post"
		save_post()
	Case "edit_post"
		edit_post()
	Case Else
		main()
End Select
footer()

sub main()
%>
<div class="gbox">
  <div style="line-height:24px;">
    <div style="float:left; margin-right:10px;">( <a href="javascript:sha(true);">展开所有内容</a> | <a href="javascript:sha(false);">收起所有内容</a> )</div>
    <%if founduser then%>
    <div style="float:left;"><a href="#newpost"><strong>立刻发表留言 » </strong></a></div>
    <%if foundadmin then%>
    <div style="float:right;"><strong>管理选项：</strong>删除多少天以前的数据：</div>
    <%end if%>
    <%end if%>
  </div>
</div>
<%
'查询串
'id,user_id,user_qq,user_email,user_ip,title,content,replay,istop,hidden,addtime,replytime
sql = "select g.id,g.user_id,g.user_ip,g.title,g.content,g.replay,g.istop,g.hidden,g.addtime,g.replytime,u.cmp_name from cmp_gbook g inner join cmp_user u on g.user_id=u.id order by addtime desc"
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
  <div class="gtitle" onmouseover="highlight(this,'#F9F9F9','#ffffff');" onclick="shc(<%=rs("id")%>);"><strong><%=HTMLEncode(rs("title"))%></strong>『<a href="userlist.asp?user_id=<%=rs("user_id")%>" target="_blank"><%=rs("cmp_name")%></a>』<span><%=rs("addtime")%></span></div>
  <div class="gcontent" id="post<%=rs("id")%>">
    <%
  	if rs("hidden")=0 or foundadmin or rs("user_id")=Session(CookieName & "_userid") then
	%>
    <%=HTMLEncode(rs("content"))%>
    <%if rs("replay")<>"" then%>
    <div class="greply"><%=HTMLEncode(rs("replay"))%></div>
	<%
	end if
	else
		response.Write("此内容设置了隐藏，仅管理员可见。")
  	end if
    %>
    <%if founduser then%>
    <%if foundadmin or rs("user_id")=Session(CookieName & "_userid") then%>
    <div class="gadmin">
    <a href="">删除</a> <a href="">编辑</a>
    <%if foundadmin then%>
    <%if rs("replay")<>"" then%>
    <a href="">编辑回复</a>
	<%else%>
    <a href="">回复</a>
    <%end if%>
    <%if rs("istop")=1 then%>
    <a href="">取消置顶</a>
	<%else%>
    <a href="">置顶</a>
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
  <div><%=showpage("zh",1,"gbook.asp",rs_nums,MaxPerPage,true,true,"条",CurrentPage)%></div>
</div>
<%
end if
else
%>
<div class="gbox"><span style="color:#FF0000;">没有找到任何相关记录</span></div>
<%
end if
rs.Close
Set rs=Nothing
'发表留言
If founduser then
	showpost() 
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
</script>
<%
end sub


sub showpost()
dim deal,formtitle,formbt,id,title,content,hidden
deal=Request.QueryString("deal")
if deal="edit" then
	id=0
	deal="edit"
	formtitle="编辑"
	formbt="修改"
	title=""
	content=""
	hidden=0
elseif deal="reply" then
	

else
	deal="add"
	formtitle="发表"
	formbt="提交"
	title=""
	content=""
	hidden=0
end if
%>
<a name="newpost"></a>
<div class="gbox">
  <table border="0" cellspacing="1" cellpadding="2" class="tablelist" width="100%">
    <form action="gbook.asp?action=save_post&deal=<%=deal%>" method="post" onSubmit="return check_post(this);">
      <%if deal="edit" then%>
      <input name="id" type="hidden" value="<%=id%>" />
      <%end if%>
      <tr>
        <th colspan="2" height="24"><strong><%=formtitle%>留言</strong></th>
      </tr>
      <tr>
        <td align="right">标题：</td>
        <td><input name="title" type="text" size="45" maxlength="200" /></td>
      </tr>
      <tr>
        <td align="right">内容：</td>
        <td><textarea name="content" cols="45" rows="10" style="width:98%;"></textarea></td>
      </tr>
      <tr>
        <td align="right">隐藏：</td>
        <td><input type="checkbox" name="hidden" value="1" />
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
	return true;
}
</script>
<%
end sub

sub save_post()
'id,user_id,user_qq,user_email,user_ip,title,content,replay,istop,hidden,addtime,replytime
'用户已经登录
If founduser and Session(CookieName & "_userid")<>"" then
	dim deal,id,title,content,hidden
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
		if foundadmin then
		
		end if
	elseif deal="reply" then
		if foundadmin then
		
		end if
	else
		if Request.Cookies(CookieName)("posttime")<>empty then
 	   		if DateDiff("s",Request.Cookies(CookieName)("posttime"),SystemTime) < 30 then
	    		ErrMsg="请不要在30秒内重复提交"
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
			cenfun_suc("gbook.asp")
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
