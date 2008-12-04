<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
addUTFBOM()
dim id,strContent
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		sql = "select config from cmp_user where id="&id
		set rs = conn.execute(sql)
		if not rs.eof then
			dim re
			strContent = UnCheckStr(rs("config"))
			Set re=new RegExp
			re.IgnoreCase =True
			re.Global=True
			re.Pattern="(<cmp[^>]+list *= *\"")[^\r]*?(\""[^>]*>)"
			if xml_make="1" then
				strContent=re.Replace(strContent,"$1" & xml_path & "/" & id & xml_list & "$2")
			else
				strContent=re.Replace(strContent,"$1list.asp?id="&id&"$2")
			end if
			Set re=nothing
		end if
		rs.close
		set rs = nothing
	end if
end if
Response.Write(strContent)
%>