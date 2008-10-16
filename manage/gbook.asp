<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
header()
menu()
Select Case Request.QueryString("action")
	Case "post"
		post()
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
            <th>标题</th>
            <th>用户</th>
            <th>时间</th>
            <th>操作</th>
          </tr>
          <%Do Until rs.EOF OR PageC=rs.PageSize%>
          <tr align="center" onMouseOver="highlight(this,'#F9F9F9','#ffffff');">
            <td><input name="checkall" type="checkbox" value="" /></td>
            <td><%=rs("user_id")%></td>
            <td><%=rs("title")%></td>
            <td><%=rs("addtime")%></td>
            <td><a href="javascript:showmsg(<%=rs("id")%>)">查看</a></td>
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
    <%If Session(CookieName & "_username")<>"" then%>
    <td width="10%" valign="top"><table border="0" cellspacing="1" cellpadding="2" class="tablelist">
        <form>
          <tr>
            <th colspan="2"><strong>发表留言</strong></th>
          </tr>
          <tr>
            <td align="right" nowrap="nowrap">&nbsp;&nbsp;用户：</td>
            <td><%=Session(CookieName & "_username")%></td>
          </tr>
          <tr>
            <td align="right">QQ：</td>
            <td><input name="qq" type="text" id="qq" maxlength="50" /></td>
          </tr>
          <tr>
            <td align="right">邮箱：</td>
            <td><input name="email" type="text" id="email" maxlength="200" /></td>
          </tr>
          <tr>
            <td align="right">标题：</td>
            <td><input name="title" type="text" id="title" size="45" maxlength="200" /></td>
          </tr>
          <tr>
            <td align="right">内容：</td>
            <td><textarea name="content" cols="45" rows="10" id="content" style="width:98%;"></textarea></td>
          </tr>
          <tr>
            <td align="right">隐藏：</td>
            <td><input type="checkbox" name="hidden" id="hidden" />
              (仅管理员可见) </td>
          </tr>
          <tr>
            <td align="right">&nbsp;</td>
            <td><input type="submit" name="button" id="button" value="提交" /></td>
          </tr>
        </form>
      </table></td>
    <%end if%>
  </tr>
</table>
<script type="text/javascript">

</script>
<%

end sub

%>
