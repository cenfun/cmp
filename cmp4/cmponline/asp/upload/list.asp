<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
addUTFBOM()
dim id,strContent
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		sql = "select list from cmp_user where id="&id
		set rs = conn.execute(sql)
		if not rs.eof then
			if trim(rs("list"))<>"" then
				strContent = UnCheckStr(rs("list"))
			end if
		end if
		rs.close
		set rs = nothing
	end if
end if
Response.Write(strContent)
%>