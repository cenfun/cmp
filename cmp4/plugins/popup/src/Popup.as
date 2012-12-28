package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.TextFormat;
	import flash.text.TextField;
	
	public class Popup extends MovieClip {
		private var api:Object;
		private var tw:Number;
		private var th:Number;
		
		private var msg:String;
		
		public function Popup():void {
			
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			
			main.bt_close.addEventListener(MouseEvent.CLICK, closeClick);
			main.visible = false;
			
			main.back.addEventListener(MouseEvent.MOUSE_DOWN, mainDown);
			
			main.multiline = true;
			main.wordWrap = true;
			
			main.message.border = true;
			main.message.borderColor = 0xcccccc;
			main.message.background = true;
			main.message.backgroundColor = 0xffffff;
			main.message.defaultTextFormat = new TextFormat("Arial", 12, 0x333333, false, false, false, null, null, null, 2, 2);
			
		}
		private function mainDown(e:MouseEvent):void {
			main.stage.addEventListener(MouseEvent.MOUSE_UP, mainUp);
			main.startDrag();
		}
		private function mainUp(e:MouseEvent):void {
			main.stage.removeEventListener(MouseEvent.MOUSE_UP, mainUp);
			main.stopDrag();
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
			
			api.addEventListener(apikey.key, "model_error", errorHandler);
			api.addEventListener(apikey.key, "model_state", stateHandler);
			api.addEventListener(apikey.key, "resize", resizeHandler);
			resizeHandler();
			
		}
		
		private function errorHandler(e:Object):void {
			
			msg = "未知错误";
			if (e.data) {
				if (e.data is Event) {
					msg = e.data.text;
				} else {
					msg = String(e.data);
				}
			}
			
			show();
			
		}
		
		private function stateHandler(e:Object):void {
			
			if (main.visible && api.config.state == "playing") {
				
				hide();
				
			}
			
		}
		
		
		private function show():void {
			if (!main.visible) {
				main.visible = true;
				main.alpha = 0;
				main.sound.play();
				main.width = 1;
				main.height = 1;
			}
			TweenNano.to(main, 0.2, {alpha:1, width:240, height:120, onComplete:showDone});
		}
		
		private function showDone():void {
			main.message.visible = true;
			main.message.text = msg;
		}
		
		
		private function hide():void {
			if (main.visible) {
				TweenNano.to(main, 0.2, {alpha:0, onComplete:hideDone});
			}
		}
		
		private function hideDone():void {
			main.message.text = "";
			main.message.visible = false;
			main.visible = false;
		}
		
		private function resizeHandler(e:Event = null):void {
			tw = api.config.width;
			th = api.config.height;
			
			main.x = Math.round(tw * 0.5);
			main.y = Math.round(th * 0.5);
		}
		
		
		public function closeClick(e:MouseEvent):void {
			
			hide();
			
		}

	}
	
}
