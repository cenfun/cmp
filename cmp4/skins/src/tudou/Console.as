package {

	import flash.display.*;
	import flash.events.*;

	public class Console extends MovieClip {
		public var api:Object;
		public var bitmapData:BitmapData;
		public function Console() {
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', removeHandler);
			
			bt_hl.useHandCursor = false;
			
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
			
			bt_hl.addEventListener(MouseEvent.CLICK, hl);
			bt_lt.addEventListener(MouseEvent.CLICK, go);
			bt_rt.addEventListener(MouseEvent.CLICK, go);
		}
		
		public function hl(e:MouseEvent):void {
			api.config.video_highlight = !api.config.video_highlight;
			api.sendEvent("video_effect");
		}
		
		public function go(e:MouseEvent):void {
			var v:int = 3;
			if (e.currentTarget == bt_lt) {
				v = -3;
			}
			api.sendEvent("view_progress", v);
		}
		
		
		public function stateHandler(e:Event = null):void {
			
		}

		public function resizeHandler(e:Event = null):void {
			var tw:Number = api.config.width;
			var th:Number = api.config.height;

			bg.width = tw;
			
			split_volume.x = tw - 34 * 3;
			split_list.x = tw - 34 * 2;
			split_fullscreen.x = tw - 34;
			
			bt_rt.x = tw - 17;
			bt_hl.x = tw - 34 * 3 - bt_hl.width - 1;
			
			
		}

	}
}