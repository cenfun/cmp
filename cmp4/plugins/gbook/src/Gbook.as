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

	public class Gbook extends MovieClip {
		public var api:Object;
		public var tw:Number;
		public var th:Number;
		
		public var gbook_xywh:String = "20,20,32,32";
		
		//延时id
		private var timeid:uint;
		
		public function Gbook() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);

			tqq.visible = false;
			tqq.tqq_tip.visible = false;
			tqq.bt_tqq.addEventListener(MouseEvent.CLICK, tqqClick);
			tqq.bt_tqq.addEventListener(MouseEvent.ROLL_OVER, tqqOver);
			tqq.bt_tqq.addEventListener(MouseEvent.ROLL_OUT, tqqOut);

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
			
			if (api.config.gbook_xywh) {
				gbook_xywh = api.config.gbook_xywh;
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
			tqq.visible = true;
			timeid = setTimeout(leave, 3000);
			
		}
		
		private function moving(e:MouseEvent = null):void {
			clearTimeout(timeid);
			if (!tqq.visible) {
				tqq.alpha = 0;
				tqq.visible = true;
			}
			if (tqq.alpha != 1) {
				TweenNano.to(tqq, 0.2, {alpha:1});
			}
		}
		//鼠标离开flash舞台区域
		private function leave(e:Event = null):void {
			clearTimeout(timeid);
			if (tqq.visible) {
				TweenNano.to(tqq, 0.2, {alpha:0, onCompleteParams:[tqq], onComplete:hideMc});
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

			var arr:Array = api.tools.strings.xywh(gbook_xywh,tw,th);

			tqq.x = arr[0];
			tqq.y = arr[1];

			tqq.bt_tqq.width = arr[2];
			tqq.bt_tqq.height = arr[3];

			tqq.tqq_tip.y = Math.round((arr[3] - tqq.tqq_tip.height) * 0.5);
			//左右
			if (arr[0] > tw * 0.5) {
				tqq.tqq_tip.bg_tip.rotation = 0;
				tqq.tqq_tip.bg_tip.x = 0;
				tqq.tqq_tip.bg_tip.y = 0;
				tqq.tqq_tip.x = 0 - tqq.tqq_tip.width - 5;

			} else {
				tqq.tqq_tip.bg_tip.rotation = 180;
				tqq.tqq_tip.bg_tip.x = tqq.tqq_tip.bg_tip.width - 5;
				tqq.tqq_tip.bg_tip.y = tqq.tqq_tip.bg_tip.height;

				tqq.tqq_tip.x = arr[2] + 10;
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

		public function tqqClick(e:MouseEvent):void {
			tqqOut(e);
			showWin();
		}
		public function tqqOver(e:MouseEvent):void {
			var mc:MovieClip = tqq.tqq_tip;
			if (! mc.visible) {
				mc.alpha = 0;
				mc.visible = true;
			}
			TweenNano.to(mc, 0.2, {alpha:1});
		}
		public function tqqOut(e:MouseEvent):void {
			var mc:MovieClip = tqq.tqq_tip;
			TweenNano.to(mc, 0.2, {alpha:0, onCompleteParams:[mc], onComplete:hideMc});
		}
		public function hideMc(mc:DisplayObject):void {
			mc.visible = false;
		}
		

	}

}