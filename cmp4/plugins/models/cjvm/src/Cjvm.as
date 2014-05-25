package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	
	public class Cjvm extends MovieClip {
		public function Cjvm():void {
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
			var api:Object = apikey.api;
			
			var version:Number = parseInt(api.config.version.substr(-6));
			if (!api.hasOwnProperty("addModel") || version < 120520) {
				var tf:TextField = new TextField();
				tf.autoSize = "left";
				tf.defaultTextFormat = new TextFormat(null, 12, 0xff0000, true);
				tf.htmlText = '<a href="http://cmp.cenfun.com/download/cmp4">当前版本CMP4不支持此插件，请点击下载并升级到最新版</a>';
				addChild(tf);
				return;
			}
			
			var cjvm:CjvmModel = new CjvmModel(apikey);
			var result:String = api.addModel(cjvm, "cjvm");
			//输出模块添加结果，看是否错误
			//api.tools.output(result);
			
		}
		
	}
	
}