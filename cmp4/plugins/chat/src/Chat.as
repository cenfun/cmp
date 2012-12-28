package {

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;
	import flash.external.*;

	public class Chat extends MovieClip {
		public var apikey:Object;
		public var api:Object;
		public var tw:Number;
		public var th:Number;
		
		public var chat_xywh:String = "20,20,32,32";
		public var chat_cchaturl:String = "http://cchat.sinaapp.com/cchat.swf";
		public var chat_alone:Boolean = false;
		
		private var loaded:Boolean = false;
		//延时id
		private var timeid:uint;
		
		public function Chat() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			win.visible = false;
			chat.visible = false;
			chat.chat_tip.visible = false;
			chat.bt_chat.addEventListener(MouseEvent.CLICK, chatClick);
			chat.bt_chat.addEventListener(MouseEvent.ROLL_OVER, chatOver);
			chat.bt_chat.addEventListener(MouseEvent.ROLL_OUT, chatOut);

		}

		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			//api.tools.output("api remove");
			api.cmp.stage.removeEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.removeEventListener(Event.MOUSE_LEAVE, leave);
			//移除所有事件，防止冲突
			clearTimeout(timeid);
		}

		private function apiHandler(e):void {
			apikey = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			
			if (api.config.chat_xywh) {
				chat_xywh = api.config.chat_xywh;
			}
			
			if (api.config.chat_alone) {
				chat_alone = api.config.chat_alone;
			}
			
			if (api.config.chat_cchaturl) {
				chat_cchaturl = api.config.chat_cchaturl;
			}

			api.addEventListener(apikey.key, "resize", resizeHandler);
			resizeHandler();
			
			api.addEventListener(apikey.key, "cchat_winclose", winclose);
			
			//显示按钮
			api.cmp.stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.addEventListener(Event.MOUSE_LEAVE, leave);
			//
			chat.visible = true;
			timeid = setTimeout(leave, 3000);
			
		}
		
		private function moving(e:MouseEvent = null):void {
			clearTimeout(timeid);
			if (win.visible) {
				chat.visible = false;
				return;
			}
			
			if (!chat.visible) {
				chat.alpha = 0;
				chat.visible = true;
			}
			if (chat.alpha != 1) {
				TweenNano.to(chat, 0.2, {alpha:1});
			}
		}
		//鼠标离开flash舞台区域
		private function leave(e:Event = null):void {
			clearTimeout(timeid);
			if (chat.visible) {
				TweenNano.to(chat, 0.2, {alpha:0, onCompleteParams:[chat], onComplete:hideMc});
			}
		}
		

		private function resizeHandler(e:Event = null):void {
			if (! api) {
				return;
			}

			tw = api.config.width;
			th = api.config.height;

			var arr:Array = api.tools.strings.xywh(chat_xywh,tw,th);

			chat.x = arr[0];
			chat.y = arr[1];

			chat.bt_chat.width = arr[2];
			chat.bt_chat.height = arr[3];

			chat.chat_tip.y = Math.round((arr[3] - chat.chat_tip.height) * 0.5);
			//左右
			if (arr[0] > tw * 0.5) {
				chat.chat_tip.bg_tip.rotation = 0;
				chat.chat_tip.bg_tip.x = 0;
				chat.chat_tip.bg_tip.y = 0;
				chat.chat_tip.x = 0 - chat.chat_tip.width - 5;

			} else {
				chat.chat_tip.bg_tip.rotation = 180;
				chat.chat_tip.bg_tip.x = chat.chat_tip.bg_tip.width - 5;
				chat.chat_tip.bg_tip.y = chat.chat_tip.bg_tip.height;

				chat.chat_tip.x = arr[2] + 10;
			}
			
		}
		//=============================================================================
		public function showWin():void {
			
			if (chat_alone) {
				
				var url:String = chat_cchaturl;
				var ok:Boolean = open(url);
				if (!ok) {
					open(url, "_self");
				}
				
				
			} else {
				
				if (loaded) {
					show();
				} else {
					load();
				}
				
			}
			
		}
		
		
		public function show():void {
			win.visible = !win.visible;
		}
		
		private function winclose(e:Object):void {
			
			win.visible = false;
			
		}
		
		public function load():void {
			
			var lc:LoaderContext = new LoaderContext();
			lc.allowCodeImport = true;
			//lc.applicationDomain = ApplicationDomain.currentDomain.parentDomain;
			//lc.securityDomain = SecurityDomain.currentDomain;
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadError, false, 0, true);
			try {
				loader.load(new URLRequest(chat_cchaturl), lc);
			} catch (e:Error) {
				loadError();
			}
			win.addChild(loader);
			win.visible = true;
		}
		
		private function loadError(e:Event = null):void {
			loaded = false;
		}
		
		private function loadComplete(e:Event):void {
			var info:LoaderInfo = e.target as LoaderInfo;
			if (!info) {
				return;
			}
			loaded = true;
			
		}
		
		
		//=============================================================================
		
		
		public function chatClick(e:MouseEvent):void {
			chatOut(e);
			showWin();
		}
		public function chatOver(e:MouseEvent):void {
			var mc:MovieClip = chat.chat_tip;
			if (! mc.visible) {
				mc.alpha = 0;
				mc.visible = true;
			}
			TweenNano.to(mc, 0.2, {alpha:1});
		}
		public function chatOut(e:MouseEvent):void {
			var mc:MovieClip = chat.chat_tip;
			TweenNano.to(mc, 0.2, {alpha:0, onCompleteParams:[mc], onComplete:hideMc});
		}
		public function hideMc(mc:DisplayObject):void {
			mc.visible = false;
		}
		
		//=============================================================================
		
		//拷贝字符串到内存
		public static function copy(str:String):Boolean {
			try {
				System.setClipboard(str);
			} catch (e:Error) {
				return false;
			}
			return true;
		}
		public static function open(url:String = "", target:String = "_blank"):Boolean {
			try {
				navigateToURL(new URLRequest(url), target);
			} catch (e:Error) {
				return false;
			}
			return true;
		}
		

	}

}