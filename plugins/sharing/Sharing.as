package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.text.*;
	import flash.utils.*;
	public class Sharing extends MovieClip {
		private var api:Object;
		private var tw:Number;
		private var th:Number;
		
		private var share_list:Array = [
		
		["qq_zone","QQ空间","http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url={url}&title={title}"],
		["qq_shuqian","QQ书签","http://shuqian.qq.com/post?from=3&jumpback=2&noui=1&uri={url}&title={title}"],
		["renren","人人网","http://share.renren.com/share/buttonshare.do?link={url}&title={title}"],
		
		["sina","新浪微博","http://v.t.sina.com.cn/share/share.php?url={url}&title={title}"],
		["sohu","白社会","http://bai.sohu.com/share/blank/addbutton.do?title={title}&link={url}"],
		["s51","51空间","http://share.51.com/share/share.php?type=8&title={title}&vaddr={url}"],
		
		["baidu","百度收藏","http://cang.baidu.com/do/add?it={title}&iu={url}"],
		["baidu_hi","百度空间","http://apps.hi.baidu.com/share/?title={title}&url={url}"],
		["douban","豆瓣网","http://www.douban.com/recommend/?url={url}&title={title}"],
		
		
		["google","谷歌书签","http://www.google.com/bookmarks/mark?op=add&bkmk={url}&title={title}"],
		["yahoo","雅虎收藏","http://myweb.cn.yahoo.com/popadd.html?src=iebookmark&url={url}&title={title}"],
		["kaixin","开心网","http://www.kaixin001.com/repaste/share.php?rtitle={title}&rurl={url}"]
		
		];
		
		private var bt_format:TextFormat = new TextFormat();
		
		private var onleft:Boolean = true;
		
		public function Sharing() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			
			var bcolor:uint = 0x555555;
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
			
			main.icons.visible = false;
			bt_format.color = 0xcccccc;
			for each(var a:Array in share_list) {
				addBT(a);
			}
			
			win.visible = false;
			win.bt_ok.addEventListener(MouseEvent.CLICK, okClick);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			//api.tools.output("api remove");
			api.cmp.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.removeEventListener(Event.MOUSE_LEAVE, leave);
		}

		private function okClick(e:MouseEvent):void {
			win.visible = false;
		}
		private function showMsg(msg:String):void {
			win.msg.htmlText = String(msg);
			win.visible = true;
		}
		
		
		private function addBT(a:Array):void {
			var mc:MovieClip = new MovieClip();
			mc.name = a[0];
			mc.link = a[2];
			//背景
			var sp:Sprite = new Sprite();
			mc.addChild(sp);
			//图标
			var icon:MovieClip = main.icons.getChildByName(a[0]);
			if (icon) {
				icon.x = 1;
				icon.y = 1;
				icon.mouseEnabled = false;
				mc.addChild(icon);
			}
			//标题
			var label:TextField = new TextField();
			label.autoSize = "left";
			label.selectable = false;
			label.mouseEnabled = false;
			label.x = 20;
			label.htmlText = a[1];
			label.setTextFormat(bt_format);
			mc.addChild(label);
			//绘制背景
			sp.graphics.beginFill(0x999999, 0.5);
			sp.graphics.drawRoundRect(0, 0, 75, 18, 5);
			sp.graphics.endFill();
			sp.alpha = 0;
			mc.bg = sp;
			//
			var index:int = main.bts.numChildren;
			var bx:int = (index % 3) * (main.bg.width + 20) / 3;
			var by:int = Math.floor(index / 3) * 24;
			mc.x = bx;
			mc.y = by;
			mc.buttonMode = true;
			mc.addEventListener(MouseEvent.CLICK, btClick);
			mc.addEventListener(MouseEvent.ROLL_OVER, btOver);
			mc.addEventListener(MouseEvent.ROLL_OUT, btOut);
			main.bts.addChild(mc);
		}
		private function btClick(e:MouseEvent):void {
			if (api) {
				var link:String = e.currentTarget.link;
				link = link.replace("{url}", encodeURIComponent(api.config.share_url));
				link = link.replace("{title}", encodeURIComponent(api.config.name));
				api.tools.strings.copy(link);
				var ok:Boolean = api.tools.strings.open(link);
				if (!ok) {
					showMsg('flash存在网络限制，无法打开窗口，已经将地址复制到剪贴板，请手动粘贴到浏览器打开');
				} else {
					showMsg('已经将地址复制到剪贴板，如果打开的窗口被拦截，请手动粘贴到浏览器打开');
				}
			}
		}
		private function btOver(e:MouseEvent):void {
			e.currentTarget.bg.alpha = 1;
		}
		private function btOut(e:MouseEvent):void {
			e.currentTarget.bg.alpha = 0;
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
			copy(main.code_flash, e.currentTarget);
		}
		private function htmlCopy(e:MouseEvent):void {
			copy(main.code_html, e.currentTarget);
		}
		public function copy(tf:TextField, tgt:*):void {
			if (api) {
				var ok:Boolean = api.tools.strings.copy(tf.text);
				if (tgt is TextField) {
					selectAllText(tf);
				} else {
					var str:String;
					if (ok) {
						str = "已经复制到剪贴板";
					} else {
						str = "无法复制，请检查Flash Player是否安装正确";
					}
					showMsg(str);
				}
			}
		}
		public function selectAllText(tf:TextField):void {
			stage.focus = tf;
			tf.setSelection(0, tf.length);
			tf.scrollH = 0;
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
			main.visible = false;
			arrow.visible = false;
			//取得播放器绝对地址并附带参数
			if (api.config.share_url) {
				main.code_flash.text = api.config.share_url;
				main.code_html.text = api.config.share_html;
			} else {
				showMsg('本分享插件(sharing.swf)需最新版本的CMP4支持，请到 <a href="http://bbs.cenfun.com/" target="_blank">http://bbs.cenfun.com/</a> 更新升级！');
				return;
			}
			
			
			api.cmp.stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.addEventListener(Event.MOUSE_LEAVE, leave);
			
			//
			share.addEventListener(MouseEvent.CLICK, shareClick);
			main.bt_close.addEventListener(MouseEvent.CLICK, mainClose);
		}
		
		private function moving(e:MouseEvent):void {
			if (main.visible) {
				return;
			}
			var sx:int = e.stageX;
			var sy:int = e.stageY;
			var ol:Boolean = false;
			if (sx < tw - share.width || sy < share.y || sy > share.y + share.height || e.buttonDown) {
				ol = true;
			}
			slideNow(ol);
			if (ol && !arrow.visible) {
				arrow.visible = true;
			} else if (!ol) {
				arrow.visible = false;
			}
		}
		//鼠标离开flash舞台区域
		private function leave(e:Event):void {
			//api.tools.output(e);
			arrow.visible = false;
			slideNow(true);
		}
		
		private function slideNow(ol:Boolean):void {
			if (ol == onleft || !api) {
				return;
			}
			onleft = ol;
			api.tools.effects.e(share);
			//api.tools.output(onleft);
			if (onleft) {
				api.tools.effects.m(share, "x", tw, tw);
			} else {
				api.tools.effects.m(share, "x", tw - 60, tw);
				startOut();
			}
		}
		
		private var tid:uint;
		private function startOut(e:MouseEvent = null):void {
			clearTimeout(tid);
			tid = setTimeout(hide, 2000);
		}
		
		private function hide():void {
			slideNow(true);
		}

		private function shareClick(e:MouseEvent):void {
			main.visible = !main.visible;
		}
		private function mainClose(e:MouseEvent):void {
			if (api) {
				api.tools.effects.f(main);
			}
		}
		
		private function resizeHandler(e:Event = null):void {
			tw = api.config.width || stage.stageWidth;
			th = api.config.height || stage.stageHeight;
			
			//播放器小于380，240将不显示
			if (tw < 380 || th < 240) {
				visible = false;
			} else {
				visible = true;
			}
			
			win.x = tw * 0.5;
			win.y = th * 0.5;
			share.x = tw;
			share.y = (th - share.height) * 0.5;
			arrow.x = tw - arrow.width;
			arrow.y = (th - arrow.height) * 0.5;
			
			main.x = (tw - main.width) * 0.5;
			main.y = (th - main.height) * 0.5;
		}
	}
	
}
