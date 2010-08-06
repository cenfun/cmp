package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.text.TextField;

	public class Sharing extends MovieClip {
		
		//QQ书签分享
		private var qq_shuqian:String = "http://shuqian.qq.com/post?from=3&jumpback=2&noui=1&uri=&title=";
		
		//分享到renren/kaixin
		private var renren:String = "http://share.renren.com/share/buttonshare.do?link=&title=";
		private var kaixin:String = "http://share.kaixin.com/share/buttonshare.do?link=&title=";
		
		//豆瓣
		private var douban:String = "http://www.douban.com/recommend/?url=&title=&comment=";
		
		//新浪微博
		private var sina:String = "http://v.t.sina.com.cn/share/share.php?url=&title=&rcontent=";
		
		//百度收藏
		private var baidu_cang:String = "http://cang.baidu.com/do/add?it=&iu=&dc=";
		//百度空间
		private var baidu_hi:String = "http://apps.hi.baidu.com/share/?title&url=";
		
		//谷歌书签
		private var google:String = "http://www.google.com/bookmarks/mark?op=add&bkmk=&title=&labels=&annotation=";
		
		//雅虎收藏
		private var yahoo:String = "http://myweb.cn.yahoo.com/popadd.html?src=iebookmark&url=&title=";


		private var api:Object;
		private var tw:Number;
		private var th:Number;
		public function Sharing() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			
			var bcolor:uint = 0x999999;
			main.code_flash.border = true;
			main.code_flash.background = true;
			main.code_flash.backgroundColor = bcolor - 0x111111;
			main.code_flash.borderColor = bcolor;
			main.code_html.border = true;
			main.code_html.background = true;
			main.code_html.backgroundColor = bcolor - 0x111111;
			main.code_html.borderColor = bcolor;
			main.code_html.text = "";
			main.bg.addEventListener(MouseEvent.MOUSE_DOWN, mainDown);
			
			main.code_flash.addEventListener(MouseEvent.CLICK, flashCopy);
			main.bt_flash.addEventListener(MouseEvent.CLICK, flashCopy);
			main.code_html.addEventListener(MouseEvent.CLICK, htmlCopy);
			main.bt_html.addEventListener(MouseEvent.CLICK, htmlCopy);
		}
		
		private function mainDown(e:MouseEvent):void {
			main.stage.addEventListener(MouseEvent.MOUSE_UP, mainUp);
			main.startDrag();
		}
		private function mainUp(e:MouseEvent):void {
			main.stage.removeEventListener(MouseEvent.MOUSE_UP, mainUp);
			main.stopDrag();
		}
		private function flashCopy(e:MouseEvent):void {
			copy(main.code_flash);
		}
		private function htmlCopy(e:MouseEvent):void {
			copy(main.code_html);
		}
		public function copy(tf:TextField):void {
			if (api) {
				api.tools.strings.copy(tf.text);
			}
			stage.focus = tf;
			tf.setSelection(0, tf.length);
			tf.scrollH = 0;
			tf.scrollV = 0;
		}
		
		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//
			api.addEventListener(apikey.key, "resize", resizeHandler);
			resizeHandler();
			api.addEventListener(apikey.key, MouseEvent.ROLL_OVER, cmpOver);
			api.addEventListener(apikey.key, MouseEvent.MOUSE_MOVE, cmpMove);
			api.addEventListener(apikey.key, MouseEvent.ROLL_OUT, cmpOut);
			init();
		}
		private function init():void {
			share.visible = false;
			main.visible = false;
			//
			share.buttonMode = true;
			share.addEventListener(MouseEvent.ROLL_OVER, shareOver);
			share.addEventListener(MouseEvent.ROLL_OUT, shareOut);
			share.addEventListener(MouseEvent.CLICK, shareClick);
			//
			main.bt_close.addEventListener(MouseEvent.CLICK, mainClose);
			//
			//取得播放器绝对地址并附带参数
			main.code_flash.text = api.config.share_url;
			main.code_html.text = api.config.share_html;
		}
		
		
		
		private function shareOver(e:MouseEvent):void {
			share.share_arrow.visible = false;
			if (api) {
				api.tools.effects.m(share, "x", tw - share.width + 10, share.width);
			}
		}
		private function shareOut(e:MouseEvent):void {
			share.share_arrow.visible = true;
			if (api) {
				api.tools.effects.m(share, "x", tw - 10, share.width);
			}
		}
		private function shareClick(e:MouseEvent):void {
			main.visible = !main.visible;
		}
		private function mainClose(e:MouseEvent):void {
			if (api) {
				api.tools.effects.f(main);
			}
		}
		
		private function cmpOver(e:MouseEvent):void {
			share.visible = true;
		}
		private function cmpMove(e:MouseEvent):void {
			if (!share.visible) {
				share.visible = true;
			}
		}
		private function cmpOut(e:MouseEvent):void {
			share.visible = false;
			share.x = tw - 10;
		}
		
		private function resizeHandler(e:Event = null):void {
			tw = api.config.width || stage.stageWidth;
			th = api.config.height || stage.stageHeight;
			
			share.x = tw - 10;
			share.y = (th - share.height) * 0.5;
			main.x = (tw - main.width) * 0.5;
			main.y = (th - main.height) * 0.5;
		}
	}
	
}
