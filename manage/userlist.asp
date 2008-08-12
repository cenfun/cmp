<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
header()
Select Case Request.QueryString("action")
	Case "hot"
		hot()
	Case Else
		main()
End Select
footer()

sub main()
	menu()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">用户列表:</th>
  </tr>
  <tr>
    <td align="left">建设中...</td>
  </tr>
</table>
<%
end sub

sub hot()
	menu()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th></th>
  </tr>
</table>
<%
end sub
%>
