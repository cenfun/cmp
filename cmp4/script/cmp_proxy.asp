<%
'CMP音乐代理，用于实现Flash跨域读取信息,以及突破防盗链
'注意：本程序为asp版，您的空间必须支持asp，使用过多将会加重服务器负担

dim url,referer
url = Request.QueryString("url")
referer = Request.QueryString("referer")

if url <> "" then
	dim obj
	Set obj = Server.CreateObject("Msxml2.ServerXMLHTTP")
	obj.open "GET",url,false 
	
	if referer <> "" then
		obj.setRequestHeader "Referer",referer
	end if

	obj.send()
	
	if obj.readystate <> 4 then
		response.Redirect(url)
	end if
	
	dim arr,filename
	arr = Split(url, "/")
	filename = arr(UBound(arr))
	'response.Write(filename)
	Response.Addheader "Content-Disposition", "attachment; filename="& filename
	Response.Addheader "Content-Transfer-Encoding", "binary"
	Response.ContentType = "application/force-download"
	Response.BinaryWrite obj.responseBody
	
	Set obj = nothing 
	
end if
%>
