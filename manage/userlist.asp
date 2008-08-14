<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
Select Case Request.QueryString("action")
	Case "hits"
		hits()
	Case Else
		header()
		menu()
		main()
		footer()
End Select

sub main()
'action=user
dim cmp_name,order,by
cmp_name=Checkstr(Request.QueryString("cmp_name"))
order=Checkstr(Request.QueryString("order"))
by=Checkstr(Request.QueryString("by"))
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <td><span style="float:left;">
      <form onSubmit="return searcher();">
        播放器名
        <input type="text" name="cmp_name" id="cmp_name" value="<%=cmp_name%>" />
        <input type="submit" name="search" id="search" value="搜索" />
      </form>
      </span> </td>
  </tr>
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form>
          <%
'查询串
sql = "select id,lasttime,hits,email,qq,cmp_name,cmp_url from cmp_user where userstatus > 4 and "
if cmp_name <> "" then
	sql = sql & " cmp_name like '%"&cmp_name&"%' and "
end if
sql = sql & " 1=1 "
if order<>"desc" then
	order = ""
end if
select case by
	case "id"
        sql = sql & " order by id " & order
	case "cmp_name"
        sql = sql & " order by cmp_name " & order
	case "hits"
        sql = sql & " order by hits " & order
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
            <th><a href="javascript:orderby('id');" title="点击按其排序">ID</a></th>
            <th><a href="javascript:orderby('cmp_name');" title="点击按其排序">播放器名</a></th>
            <th><a href="javascript:orderby('hits');" title="点击按其排序">查看次数</a></th>
            <th><a href="javascript:orderby('lasttime');" title="点击按其排序">最后更新</a></th>
            <th>Email</th>
            <th>QQ</th>
            <th align="left">CMP播放器地址</th>
          </tr>
          <%Do Until rs.EOF OR PageC=rs.PageSize%>
          <tr align="center" onMouseOver="highlight(this,'#F9F9F9','#ffffff');">
            <td><%=rs("id")%></td>
            <td><a href="<%=getCmpPageUrl(rs("id"))%>" target="_blank" title="点击打开播放器页面"><%=rs("cmp_name")%></a></td>
            <td><%=rs("hits")%></td>
            <td><%=FormatDateTime(rs("lasttime"),2)%></td>
            <td><a href="mailto:<%=rs("email")%>" target="_blank"><%=rs("email")%></a></td>
            <td><a href="<%=getQqUrl(rs("qq"))%>" target="_blank"><%=rs("qq")%></a></td>
            <td align="left"><a href="<%=getCmpUrl(rs("id"))%>&" target="_blank" onclick="addHits(<%=rs("id")%>);"><%=getCmpUrl(rs("id"))%></a></td>
          </tr>
          <%rs.MoveNext%>
          <%PageC=PageC+1%>
          <%loop%>
          <tr>
            <td colspan="10"><div style="float:right;padding-top:5px;"><%=showpage("zh",1,"userlist.asp?cmp_name="&cmp_name&"&order="&order&"&by="&by&"",rs_nums,MaxPerPage,true,true,"个",CurrentPage)%></div></td>
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
function searcher() {
	var str = document.getElementById("cmp_name").value;
	if(str != "<%=cmp_name%>"){
		window.location = "userlist.asp?cmp_name="+str+"&order=<%=order%>&by=<%=by%>";
	}
	return false;
}
function orderby(by) {
	var order = "<%=order%>"=="desc"?"":"desc";
	window.location = "userlist.asp?cmp_name=<%=cmp_name%>&order="+order+"&by="+by;
}
function addHits(id) {
	ajaxSend("GET","userlist.asp?action=hits&rd="+Math.round()+"&id="+id,true,null,completeHd,errorHd);
}
function completeHd(data){
	//alert(data);
}
function errorHd(errmsg){
	//alert(errmsg);
}
</script>
<%
end sub

sub hits()
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		'更新点击数
		if Session(CookieName & id)="" then
			Session(CookieName & id) = id
			conn.execute("update cmp_user set hits=hits+1 where id="&id&" ")
		end if
	end if
end if
end sub
%>
