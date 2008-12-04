<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
addUTFBOM()
dim id,strContent
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		sql = "select cmp_name,cmp_url,config from cmp_user where userstatus > 4 and id=" & id
		set rs = conn.execute(sql)
		if not rs.eof then
			if trim(rs("config"))<>"" then
				strContent = UnCheckStr(rs("config"))
				strContent = setLNU(strContent, xml_make, xml_path, xml_list, id, rs("cmp_name"), rs("cmp_url"))
			else
				dim cr,lPath
				cr = Chr(13) & Chr(10)  & Chr(13) & Chr(10) 
				if xml_make="1" then
					lPath = xml_path & "/" & id & xml_list
				else
					lPath = "list.asp?id="&id
				end if
				strContent = "<cmp name="""&rs("cmp_name")&""" url="""&rs("cmp_url")&""" list="""&lPath&""" >" & cr
				strContent = strContent & "<config language="""" play_mode="""" skin_id="""" list_id="""" volume="""" auto_play="""" max_video="""" bgcolor="""" "
				strContent = strContent & "mixer_id="""" mixer_color="""" mixer_filter="""" mixer_displace="""" "
				strContent = strContent & "buffer="""" timeout="""" show_tip="""" context_menu="""" video_smoothing="""" plugins_disabled="""" check_policyfile=""""  />" & cr
				strContent = strContent & "<skins />" & cr 
				strContent = strContent & "<plugins />" & cr
				strContent = strContent & "<nolrc src="""" />" & cr
				strContent = strContent & "<count src="""&XMLEncode(site_count)&""" />" & cr
				strContent = strContent & "</cmp>"
				conn.execute("update cmp_user set config='"&CheckStr(strContent)&"' where id=" & id & " ")
			end if
		end if
		rs.close
		set rs = nothing
	end if
end if
Response.Write(strContent)
%>