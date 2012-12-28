package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.*;
	import flash.system.*;
	import flash.ui.*;

	public class QuickKeys extends MovieClip {
		private var api:Object;
		private var config:Array;
		public function QuickKeys() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
		}
		
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		private function removeHandler(e):void {
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			if (!api.config.quickkeys_config) {
				return;
			}
			
			config = [];
			var arr:Array = api.config.quickkeys_config.split(/\s*\,\s*/);
			if (arr.length) {
				for each(var s:String in arr) {
					var a:Array = s.split(/\s*\:\s*/);
					if (a[1]) {
						var key:Object = newKey(a[1]);
						key.event = a[0];
						config.push(key);
					}
				}
			}
			
			//api.tools.output(config);
			if (config.length) {
				
				api.config.shortcuts = false;
				api.cmp.stage.addEventListener(KeyboardEvent.KEY_UP, kbHandler, false, 100);
				
			}
			
		}
		
		public function kbHandler(e:KeyboardEvent):void {
			//api.tools.output("keyUpHd: " + e.keyCode +"|"+ e.ctrlKey +"|"+ e.altKey +"|"+ e.shiftKey);
			
			for each(var k:Object in config) {
				if (e.keyCode == k.keyCode && e.ctrlKey == k.ctrlKey && e.altKey == k.altKey && e.shiftKey == k.shiftKey) {
					api.sendEvent(k.event);
					e.stopImmediatePropagation();
					break;
				}
			}
			
		}
		
		public function newKey(str:String):Object {
			var key:Object = {
				keyCode : 0,
				ctrlKey : false,
				altKey : false,
				shiftKey : false
			};
			
			//api.tools.output(str);
			
			var arr:Array = str.split(/\s*\+\s*/);
			while (arr.length) {
				var v:String = arr.shift().toUpperCase();
				if (v == "CTRL") {
					key.ctrlKey = true;
				} else if (v == "ALT") {
					key.altKey = true;
				} else if (v == "SHIFT") {
					key.shiftKey = true;
				} else {
					key.keyCode = Keyboard[v];
					//api.tools.output(key.keyCode, v);
				}
			
			}
			return key;
		}

	}

}