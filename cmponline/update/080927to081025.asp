<!--#include file="../conn.asp"-->
<%
dbpath = "../"
%>
<!--#include file="../const.asp"-->
<%header()%>
<form method="post" action="?action=up" onsubmit="return check();">
  <table width="90%" border="0" align="center" cellpadding="5" cellspacing="3">
    <tr>
      <td><strong>CMP Manage 080927数据库升级为081025数据库程序：</strong></td>
    </tr>
    <tr>
      <td>您要操作的数据库文件位置：<%=dbpath & sitedb%></td>
    </tr>
    <tr>
      <td><strong style="color:#FF0000">注意：升级前请务必备份好原有数据库，防止意外情况丢失数据</strong></td>
    </tr>
    <tr>
      <td>更新记录：
        <blockquote>
          <li>删除cmp_gbook表字段user_qq,user_email,replay</li>
          <li>新增cmp_gbook表字段reply text with compression</li>
          <li>新增cmp_skins表字段bgcolor char(10)</li>
        </blockquote></td>
    </tr>
    <tr>
      <td><input type="submit" name="Submit" value="立即升级" /></td>
    </tr>
    <tr>
      <td><% 
if request("action")="up" then
	'on error resume next
	conn.execute("alter table cmp_gbook drop column user_qq,user_email,replay")
	conn.execute("alter table cmp_gbook add column reply text with compression")
	conn.execute("alter table cmp_skins add column bgcolor char(10) with compression")
%>
        <blockquote>
          <li>升级数据库完成！ </li>
          <li>请立即对新的系统进行测试，以确保无误！</li>
          <li>测试无误后，请及时删除本更新程序和update更新程序目录，以防止他人再次运行！</li>
        </blockquote>
        <%
end if
%>
      </td>
    </tr>
  </table>
</form>
<script type="text/javascript">
function check() {
	if (confirm("确定要执行操作吗？")) {
		return true;
	}
	return false;
}
</script>
<%footer()%>
