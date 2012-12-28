package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	
	public class CDN extends MovieClip {
		public var api:Object;
		
		public var cdn_handler:String;
		public var cdn_url:String;
		public var cdn_type:String;
		
		public function CDN():void {
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
			// 代理
			api.addProxy("cdn", callback);
			
		}
		
		public function callback(...rest):void {
			
			cdn_handler = rest[0];
			cdn_url = rest[1];
			cdn_type = rest[2];
			
			//api.tools.output(rest);
			
			
			if (!cdn_handler || !cdn_url) {
				api.sendEvent("model_error", "参数不正确");
				return;
			}
			
			api.sendState("connecting");
			
			//加载文件信息
			var req:URLRequest = new URLRequest(cdn_url);
			new MyLoader(req, onError, onProgress, onCDNComplete);
			
		}
		
		
		public function onError(e:Event = null):void {
			api.sendEvent("model_error", "加载视频配置失败");
		}
		private function onProgress(ebl:uint, ebt:uint):void {
		}
		//信息加载完成
		public function onCDNComplete(ba:ByteArray):void {
			var str:String = ba.toString();
			//api.tools.output(str);
			
			if (!str) {
				api.sendEvent("model_error", "无法获取CDN数据");
				return;
			}
			
			var req:URLRequest = new URLRequest(cdn_handler);
			
			var variables:URLVariables = new URLVariables();
            variables.data = str;
            req.data = variables;
			req.method = URLRequestMethod.POST;
			
			new MyLoader(req, onError, onProgress, onDataComplete);
			
		}
		
		public function onDataComplete(ba:ByteArray):void {
			
			
			var str:String = ba.toString();
			//api.tools.output(str);
			if (!str) {
				api.sendEvent("model_error", "无法获取CDN处理后的数据");
				return;
			}
			
			//api.tools.output(cdn_type);
			
			//指定特殊类型的，比如merge，保存到特定的数据
			if (cdn_type) {
				api.item["data_" + cdn_type] = ba;
			}
			
			//默认的url地址类型
			api.sendEvent("model_load", str);
			
		}
		
		
		
	}
	
}