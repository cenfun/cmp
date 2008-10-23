<!--#include file="conn.asp"-->
<!--#include file="const.asp"-->
<% 
header()
menu()
main()
footer()

sub main()
%>
<style type="text/css">
.mbox {padding:8px 10px; border-bottom:1px dashed #CCCCCC;}
</style>
<script type="text/javascript">

</script>
<table border="0" cellpadding="2" cellspacing="1" class="tableborder" width="98%">
  <tr>
    <th align="left">迷你播放器</th>
  </tr>
  <tr>
    <td><div>
        <div class="mbox">当你在发表信息时，如果想要快捷的插入某个音乐或视频，这里免费提供各种Mini播放器供您使用，无需注册，仅仅填写你要播放的音乐或视频地址即可。</div>
        <div class="mbox"><strong>音乐或视频地址：</strong><span>(mp3,flv)</span>
          <div>
            <input name="" type="text" size="100" />
          </div>
        </div>
        <div class="mbox"><strong>选择你想要的风格：</strong>
          <div>
            <select name="">
            </select>
          </div>
        </div>
        <div class="mbox"><strong>播放器设置：</strong>
          <table border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td align="right">自动播放：</td>
              <td><input name="" type="checkbox" value="" /></td>
            </tr>
            <tr>
              <td align="right">循环播放：</td>
              <td><input name="" type="checkbox" value="" /></td>
            </tr>
            <tr>
              <td align="right">背景颜色：</td>
              <td><input type="text" size="7" maxlength="7" />
                默认为#181818</td>
            </tr>
            <tr>
              <td align="right">宽度高度：</td>
              <td><input type="text" size="4" />
                x
                  <input type="text" size="4" /></td>
            </tr>
          </table>
        </div>
        <div class="mbox"><strong>效果预览：</strong>
          <div id="preview"></div>
        </div>
        <div class="mbox"><strong>调用代码：</strong>
          <div>
            <textarea name="" cols="100" rows="5"></textarea>
          </div>
        </div>
      </div></td>
  </tr>
</table>
<%
end sub
%>
