<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
header()
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
if IsNumeric(id) then
	set rs = conn.execute("select cmp_name from cmp_user where id="&id&" ")
	if not rs.eof then
		'取得页面标题
		if rs("cmp_name") <> "" then
			response.Write("<script type=""text/javascript"">document.title="""&rs("cmp_name")&""";</script>")	
		end if
%>
<script type="text/javascript">
//CMP v3.0 show 
//id, width, height, cmp url, vars
showcmp("cmp", "100%", "100%", "cmp.swf", "url=<%=geturl(id)%>");
</script>
<%
	end if
	rs.close
	set rs = nothing
end if
end if
%>
</body>
</html>
