package {

	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.net.URLLoader;
	import flash.media.Video;

	public class AgeGate extends MovieClip {
		public var api:Object;
		public var agegate_mode:String = "1";
		public var auto_play:Boolean = false;
		public function AgeGate():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
		}
		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			if (api.config.agegate_mode) {
				agegate_mode = api.config.agegate_mode;
			}
			
			api.addEventListener(apikey.key, "resize", resize);
			
			init();
			
			
		}
		private function init():void {
			
			auto_play = api.config.auto_play;
			api.config.auto_play = false;
			
			mode1.bt_agree.addEventListener(MouseEvent.CLICK, agreeClick);
			mode1.bt_leave.addEventListener(MouseEvent.CLICK, leaveClick);
			
			layout();
		}
		private function resize(e:Event):void {
			layout();
		}
		
		private function agreeClick(e:MouseEvent):void {
			visible = false;
			api.removeEventListener("resize", resize);
			if (auto_play) {
				api.sendEvent("view_play");
			}
		}
		private function leaveClick(e:MouseEvent):void {
			mode1.bt_agree.visible = false;
			mode1.bt_leave.visible = false;
			mode1.msg.text = "Thanks! 谢谢！";
		}
		
		private function layout():void {
			
			var tw:int = api.config.width;
			var th:int = api.config.height;
			
			back.width = tw;
			back.height = th;
			
			mode1.x = (tw - mode1.width) * 0.5;
			mode1.y = (th - mode1.height) * 0.5;
			
		}
		
	}

}