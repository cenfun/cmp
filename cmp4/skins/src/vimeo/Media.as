package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	
	public class Media extends Sprite {
		private var api:Object;
		public function Media() {
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', apiRemoveHandler);
		}
		override public function set width(v:Number):void {
			back.width = v;
			logo.x = (v - logo.width) * 0.5;
		}
		override public function set height(v:Number):void {
			back.height = v;
			logo.y = (v - logo.height) * 0.5;
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
		}
		private function apiRemoveHandler(e:Event = null):void {
		}

		

	}

}