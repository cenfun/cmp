package {

	import flash.display.*;
	import flash.events.*;
	import flash.system.Security;

	public class Console extends MovieClip {
		public var api:Object;
		public var tw:int;
		public var th:int;
		
		
		public var bitmapData:BitmapData;
		public function Console() {
			flash.system.Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
			console.buffering.visible = false;
		}
		
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		
		public function removeHandler(e):void {
			
		}

		public function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			stateHandler();
			resizeHandler();
			
		}
		
		public function stateHandler(e:Event = null):void {
			
			console.buffering.visible = false;
			
			if (api.config.state == "buffering" || api.config.state == "connecting") {
				console.buffering.visible = true;
			}
			
			
		}

		public function resizeHandler(e:Event = null):void {
			tw = api.config.width;
			th = api.config.height;

			
			
			
		}

	}
}