<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
header()
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
%>
<script type="text/javascript">
//CMP v3.0 show 
//id, width, height, cmp url, vars
showcmp("cmp", "100%", "100%", "cmp.swf", "url=<%=geturl(id)%>");
</script>
<%
	end if
end if
%>
</body>
</html>
