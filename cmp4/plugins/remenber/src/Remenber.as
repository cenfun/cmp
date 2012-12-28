package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	
	public class Remenber extends MovieClip {
		public var tf:TextField;
		public var api:Object;
		public function Remenber():void {
			Security.allowDomain("*");
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
			//
			var version:Number = parseInt(api.config.version.substr(-6));
			if (!api.hasOwnProperty("addModel") || version < 120520) {
				showError('<a href="http://cmp.cenfun.com/download/cmp4">当前版本CMP4不支持remenber插件，请点击下载并升级到最新版</a>');
				return;
			}
			
			api.addEventListener(apikey.key, "model_time", timeHandler);
			api.addEventListener(apikey.key, "view_stop", stopHandler);
			
			//必须在CMP的模块加载前设置，所以优先级设置为100
			api.addEventListener(apikey.key, "model_load", loadHandler, false, 100);
		}
		
		public function timeHandler(e:Object = null):void {
			var item:Object = api.item;
			if (item && item.type == "video" && item.stream) {
				//实时保存当前位置
				if (item.start_bytes) {
					api.cookie("start_bytes", item.start_bytes);
				}
				if (item.start_seconds) {
					api.cookie("start_seconds", item.start_seconds);
				}
			}
		}
		
		public function stopHandler(e:Object = null):void {
			var item:Object = api.item;
			if (item && item.type == "video" && item.stream) {
				api.cookie("start_bytes", 0);
				api.cookie("start_seconds", 0);
			}
		}
		public function loadHandler(e:Object = null):void {
			//自动恢复到当前项
			if (api.config.start_bytes && !api.item.start_bytes) {
				api.item.start_bytes = api.config.start_bytes; 
			}
			if (api.config.start_seconds && !api.item.start_seconds) {
				api.item.start_seconds = api.config.start_seconds; 
			}
			
		}
		
		public function showError(msg:String):void {
			if (!tf) {
				tf = new TextField();
				tf.autoSize = "left";
				tf.defaultTextFormat = new TextFormat(null, 12, 0xff0000, true);
			}
			tf.htmlText = '' + msg;
			addChild(tf);
		}
		
	}
	
}