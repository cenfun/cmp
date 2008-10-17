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
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <td width="90%" valign="top"><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form>
          <%
'查询串
'id,user_id,user_qq,user_email,user_ip,title,content,replay,istop,hidden,addtime,replytime
sql = "select id,user_id,user_qq,user_email,user_ip,title,content,replay,istop,hidden,addtime,replytime from cmp_gbook order by addtime desc"
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
	MaxPerPage=50
set rs=Server.CreateObject("ADODB.RecordSet")
rs.Open sql,conn,1,1
IF not rs.EOF Then
	rs.PageSize=MaxPerPage
	rs.AbsolutePage=CurrentPage
	Dim rs_nums
	rs_nums=rs.RecordCount
	%>
          <tr>
            <th><input name="checkall" type="checkbox" value="" /></th>
            <th align="left">标题</th>
            <th>用户</th>
            <th>发表时间</th>
          </tr>
          <%Do Until rs.EOF OR PageC=rs.PageSize%>
          <tr align="center" onMouseOver="highlight(this,'#F9F9F9','#ffffff');">
            <td><input name="checkall" type="checkbox" value="" /></td>
            <td align="left"><a href="javascript:showmsg(<%=rs("id")%>)"><%=rs("title")%></a></td>
            <td><%=rs("user_id")%></td>
            <td><%=rs("addtime")%></td>
          </tr>
          <%rs.MoveNext%>
          <%PageC=PageC+1%>
          <%loop%>
          <tr>
            <td colspan="5"><div style="float:right;padding-top:5px;"><%=showpage("zh",1,"gbook.asp",rs_nums,MaxPerPage,true,true,"条",CurrentPage)%></div></td>
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
    <%
	If Session(CookieName & "_username")<>"" then
		response.Write("<td width=""10%"" valign=""top"">")
		showpost() 
		if Session(CookieName & "_admin")<>"" then
			showadmin()
		end if
		response.Write("</td>")
    end if
	%>
  </tr>
</table>
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
<table border="0" cellspacing="1" cellpadding="2" class="tablelist">
  <form action="gbook.asp?action=save_post&deal=<%=deal%>" method="post" onSubmit="return check_post(this);">
    <%if deal="edit" then%>
    <input name="id" type="hidden" value="<%=id%>" />
    <%end if%>
    <tr>
      <th colspan="2"><strong><%=formtitle%>留言</strong></th>
    </tr>
    <tr>
      <td align="right" nowrap="nowrap">&nbsp;&nbsp;用户：</td>
      <td><%=Session(CookieName & "_username")%></td>
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
If Session(CookieName & "_userid")<>"" then
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
		if Session(CookieName & "_admin")<>"" then
		
		end if
	elseif deal="reply" then
		
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
end if
end sub


sub showadmin()
%>
<br />
<table border="0" cellspacing="1" cellpadding="2" class="tablelist" width="100%">
  <tr>
    <th><strong>管理选项</strong></th>
  </tr>
  <tr>
    <td>删除多少天以前的数据：</td>
  </tr>
</table>
<%
end sub

%>
