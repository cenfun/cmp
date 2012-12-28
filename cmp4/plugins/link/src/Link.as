package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	
	public class Link extends MovieClip {
		public var api:Object;
		
		public function Link():void {
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
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
			// 代理
			api.addProxy("link", callback);
			
		}
		
		public function callback(url:String, ...rest):void {
			if (!url) {
				api.sendEvent("model_error", "没有链接地址");
				return;
			}
			
			var window:String = "_blank";
			
			if (rest[0]) {
				window = rest[0];
			}
			
			var req:URLRequest = new URLRequest(url);
			
			navigateToURL(req, window);
			
			//自动播放下一个
			if (rest[1] && window == "_blank") {
				api.sendState("completed");
			}
			
			
		}
		
	}
	
}