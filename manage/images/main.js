function checkspace(checkstr) {
  var str = '';
  for(i = 0; i < checkstr.length; i++) {
    str = str + ' ';
  }
  return (str == checkstr);
}
function check()
{
  if(checkspace(document.form1.admin.value)) {
	document.form1.admin.focus();
    alert("用户名不能为空！");
	return false;
  }
  if(checkspace(document.form1.password.value)) {
	document.form1.password.focus();
    alert("密码不能为空！");
	return false;
  }
    if(checkspace(document.form1.verifycode.value)) {
	document.form1.verifycode.focus();
    alert("请输入验证码！");
	return false;
  }
	return true;
}