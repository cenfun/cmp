package {

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;
	import flash.external.*;
	import com.cenfun.*;

	public class Weibo extends MovieClip {
		public var api:Object;
		public var tw:Number;
		public var th:Number;
		
		public var weibo_xywh:String = "20,20,32,32";
		
		//延时id
		private var timeid:uint;
		
		public function Weibo() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);

			weibo.visible = false;
			weibo.weibo_tip.visible = false;
			weibo.bt_weibo.addEventListener(MouseEvent.CLICK, weiboClick);
			weibo.bt_weibo.addEventListener(MouseEvent.ROLL_OVER, weiboOver);
			weibo.bt_weibo.addEventListener(MouseEvent.ROLL_OUT, weiboOut);

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
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			win.apiHandler(api);
			
			if (api.config.weibo_xywh) {
				weibo_xywh = api.config.weibo_xywh;
			}
			
			api.addEventListener(apikey.key, "model_state", stateHandler);
			stateHandler();

			api.addEventListener(apikey.key, "resize", resizeHandler);
			resizeHandler();
			
			win.bt_pause.addEventListener(MouseEvent.CLICK, playClick);
			win.bt_play.addEventListener(MouseEvent.CLICK, playClick);
			win.bt_stop.addEventListener(MouseEvent.CLICK, stopClick);
			
			//显示按钮
			api.cmp.stage.addEventListener(MouseEvent.MOUSE_MOVE, moving);
			api.cmp.stage.addEventListener(Event.MOUSE_LEAVE, leave);
			//
			weibo.visible = true;
			timeid = setTimeout(leave, 3000);
			
		}
		
		private function moving(e:MouseEvent = null):void {
			clearTimeout(timeid);
			if (!weibo.visible) {
				weibo.alpha = 0;
				weibo.visible = true;
			}
			if (weibo.alpha != 1) {
				TweenNano.to(weibo, 0.2, {alpha:1});
			}
		}
		//鼠标离开flash舞台区域
		private function leave(e:Event = null):void {
			clearTimeout(timeid);
			if (weibo.visible) {
				TweenNano.to(weibo, 0.2, {alpha:0, onCompleteParams:[weibo], onComplete:hideMc});
			}
		}
		
		public function playClick(e:MouseEvent):void {
			if (api) {
				api.sendEvent("view_play");
			}
		}
		
		public function stopClick(e:MouseEvent):void {
			if (api) {
				api.sendEvent("view_stop");
			}
		}
		
		private function stateHandler(e:Event = null):void {
			if (! api) {
				return;
			}
			if (api.config.state == "playing" || api.config.state == "connecting" || api.config.state == "buffering") {
				win.bt_pause.visible = true;
				win.bt_play.visible = false;
			} else {
				win.bt_pause.visible = false;
				win.bt_play.visible = true;
			}
		}

		private function resizeHandler(e:Event = null):void {
			if (! api) {
				return;
			}

			tw = api.config.width;
			th = api.config.height;

			var arr:Array = api.tools.strings.xywh(weibo_xywh,tw,th);

			weibo.x = arr[0];
			weibo.y = arr[1];

			weibo.bt_weibo.width = arr[2];
			weibo.bt_weibo.height = arr[3];

			weibo.weibo_tip.y = Math.round((arr[3] - weibo.weibo_tip.height) * 0.5);
			//左右
			if (arr[0] > tw * 0.5) {
				weibo.weibo_tip.bg_tip.rotation = 0;
				weibo.weibo_tip.bg_tip.x = 0;
				weibo.weibo_tip.bg_tip.y = 0;
				weibo.weibo_tip.x = 0 - weibo.weibo_tip.width - 5;

			} else {
				weibo.weibo_tip.bg_tip.rotation = 180;
				weibo.weibo_tip.bg_tip.x = weibo.weibo_tip.bg_tip.width - 5;
				weibo.weibo_tip.bg_tip.y = weibo.weibo_tip.bg_tip.height;

				weibo.weibo_tip.x = arr[2] + 10;
			}


			win.resizeHandler(tw, th);

			
			win.bt_pause.x = win.bt_play.x = tw - 90;
			win.bt_stop.x = tw - 60;
			
		}

		public function showWin():void {
			if (win.visible) {
				win.hide();
			} else {
				win.show();
			}
		}

		public function weiboClick(e:MouseEvent):void {
			weiboOut(e);
			showWin();
		}
		public function weiboOver(e:MouseEvent):void {
			var mc:MovieClip = weibo.weibo_tip;
			if (! mc.visible) {
				mc.alpha = 0;
				mc.visible = true;
			}
			TweenNano.to(mc, 0.2, {alpha:1});
		}
		public function weiboOut(e:MouseEvent):void {
			var mc:MovieClip = weibo.weibo_tip;
			TweenNano.to(mc, 0.2, {alpha:0, onCompleteParams:[mc], onComplete:hideMc});
		}
		public function hideMc(mc:DisplayObject):void {
			mc.visible = false;
		}
		

	}

}