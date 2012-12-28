package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	
	public class CEL extends MovieClip {
		public var tf:TextField;
		public var api:Object;
		public function CEL():void {
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
			//
			var version:Number = parseInt(api.config.version.substr(-6));
			if (!api.hasOwnProperty("setCELH") || version < 120729) {
				showError('<a href="http://cmp.cenfun.com/download/cmp4">当前版本CMP4不支持cel插件，请点击下载并升级到最新版</a>');
				return;
			}
			
			api.setCELH(celHandler);
			
		}
		
		public function celHandler(str:String):String {
			if (str) {
				var s3:String = str.substr(0, 3);
				if (s3 == "CEL") {
					var s:String = str.substr(3);
					//test
					str = s.substr(3);
				}
			}
			return str;
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