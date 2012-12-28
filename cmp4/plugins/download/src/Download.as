package {

	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;

	public class Download extends MovieClip {

		public var api:Object;
		
		public var urlname:String = "url";
		
		public function Download() {
			main.copy.visible = false;
			
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
			
			if (api.config.download_autohide) {
				api.addEventListener(apikey.key, "model_state", stateHandler);
				stateHandler();
			}
			
			if (api.config.download_urlname) {
				urlname = api.config.download_urlname;
			}
			
			var tx:int = parseInt(api.config.download_x);
			if (tx) {
				x = tx;
			}
			var ty:int = parseInt(api.config.download_y);
			if (ty) {
				y = ty;
			}
			
			main.download.addEventListener(MouseEvent.CLICK, downloadclick);
		}
		public function downloadclick(e:Event):void {
			if (!api.item) {
				return;
			}
			
			var url:String = api.item[urlname];
			if (!url) {
				url = api.item.url;
			}
			var request:URLRequest = new URLRequest(url);
			copyUrl(url);
			try {
				navigateToURL(request, "_blank");
			} catch (e:Error) {
			}
		}

		public function copyUrl(url:String):void {
			try {
				System.setClipboard(url);
			} catch (e:Error) {
				return;
			}
			main.copy.visible = true;
			main.download.visible = false;
			setTimeout(back, 1000);
		}

		public function back():void {
			main.copy.visible = false;
			main.download.visible = true;
		}

		public function stateHandler(e:Event = null):void {
			var state:String = api.config["state"];
			if (state == "playing" || state == "paused") {
				main.visible = true;
			} else {
				main.visible = false;
			}
		}

	}

}