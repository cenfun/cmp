package {

	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;

	public class Capture extends MovieClip {

		public var api:Object;
		
		public function Capture() {
			
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
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
			
			var tx:int = parseInt(api.config.capture_x);
			if (tx) {
				x = tx;
			}
			var ty:int = parseInt(api.config.capture_y);
			if (ty) {
				y = ty;
			}
			
			main.addEventListener(MouseEvent.CLICK, captureclick);
			
		}
		public function captureclick(e:Event):void {
			
			var bd:BitmapData = new BitmapData(api.config.video_width, api.config.video_height);
			try {
				bd.draw(api.win_list.media.video);
			} catch (e:Error) {
				return;
			}
			
			var file:FileReference = new FileReference();  
			var ba:ByteArray = PNG.encode(bd);
			file.save(ba, "cmp_capture_" + (Math.random().toString().substr(2)) + ".png"); 
			
		}
		

	}

}