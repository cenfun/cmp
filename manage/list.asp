<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		sql = "select list from cmp_user where id="&id
		set rs = conn.execute(sql)
		if not rs.eof then
			response.Write(rs("list"))
		end if
		rs.close
		set rs = nothing
	end if
end if
%>