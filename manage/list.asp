<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
Response.BinaryWrite(ChrB(239))
Response.BinaryWrite(ChrB(187))
Response.BinaryWrite(ChrB(191))
%>
<%
dim id
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		sql = "select list from cmp_user where id="&id
		set rs = conn.execute(sql)
		if not rs.eof then
			response.Charset = "utf-8"
			response.AddHeader "Content-Type", "text/xml"
			response.Write(rs("list"))
		end if
		rs.close
		set rs = nothing
	end if
end if
%>