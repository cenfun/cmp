<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<%
dim id,strContent
id=Checkstr(Request.QueryString("id"))
if id <> "" then
	if IsNumeric(id) then
		dim str,url
		
		if xml_make = "1" then
			'支持从缓存文件读取
			url = xml_path & "/" & id & xml_config
			if isFileExists(url)=true then
				str = readFile(url)
			else
				str = getConfig(id)
				call makeFile(url, str)
			end if
		else
			str = getConfig(id)
		end if

		addUTFBOM()
		Response.Write(UnCheckStr(str))
		
	end if
end if

%>