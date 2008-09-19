<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
header()
menu()
Select Case Request.QueryString("action")
	Case "hits"
		hits()
	Case Else
		main()
End Select
footer()

sub main()
%>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <td><table border="0" cellpadding="2" cellspacing="1" class="tablelist" width="100%">
        <form>
制作中...
        </form>
      </table></td>
  </tr>
</table>
<script type="text/javascript">

</script>
<%
end sub

%>
