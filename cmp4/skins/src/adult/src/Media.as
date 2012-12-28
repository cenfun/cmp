package {

	import flash.display.*;
	import flash.events.*;

	public class Media extends MovieClip {
		public var api:Object;
		public var bitmapData:BitmapData;
		public function Media() {
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
		}
		
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		
		public function removeHandler(e):void {
			
			//api.tools.output("api remove");
			
		}

		public function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			//api.tools.output("api add");
			
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			stateHandler();
			resizeHandler();
		}
		public function stateHandler(e:Event = null):void {
			if (api.item && api.item.type == "video" && api.config.state != "stopped") {
				mm.visible = false;
			} else {
				mm.visible = true;
			}
		}

		public function resizeHandler(e:Event = null):void {
			var tw:Number = api.config.video_width;
			var th:Number = api.config.video_height;

			bg.width = tw;
			bg.height = th;
			
			api.tools.zoom.fit(mm, tw, th, 0);
			
		}

	}
}