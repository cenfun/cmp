package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;

	public class Sina extends Object {
		public var api:Object;
		//
		private var dataurl:String = "http://v.iask.com/v_play.php?vid=";
		//当前地址列表
		private var file_list:Array;
		//第几段，sina默认开始为1
		private var file_index:int = 1;
		
		public function Sina(_api:Object):void {
			api = _api;
		}
		
		public function callback(vids:String, index:int = 1, ...rest):void {
			if (!vids) {
				api.sendEvent("model_error", "没有代理函数的参数值");
				return;
			}
			file_index = index;
			//api.tools.output(vids, index);
			api.sendState("connecting");
			load(vids);
		}
		
		private function load(vids:String):void {
			var url:String = dataurl + vids + "pid=0&tid=0&referrer=null&ran="+Math.random()+"&r=null";
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(Event.COMPLETE, onLoaded);
			var req:URLRequest = new URLRequest(url);
			try {
				loader.load(req);
			} catch (e:Error) {
				onError();
			}
			
		}
		
		private function onError(e:Event = null):void {
			api.sendEvent("model_error", "加载视频配置失败");
		}
		private function onProgress(e:ProgressEvent):void {
			
		}
		private function onLoaded(e:Event):void {
			//sina是u8的编码，无BOM
			System.useCodePage = false;
			var str:String = e.target.data.toString();
			System.useCodePage = true;
			//
			try {
				var xml:XML = new XML(str);
			} catch(e:Error) {
				onError();
				return;
			}
			
			parse(xml);
			
		}
		private function parse(xml:XML):void {
			//api.tools.output(xml.toXMLString());
			//计算所有分段地址列表
			file_list = [];
			//
			//分段
			var durl:XMLList = xml.durl;
			if (durl is XMLList && durl.length()) {
				var n:int;
				var u:String;
				for each (var item:XML in durl) {
					n = parseInt(item.order);
					u = item.url.text();
					if (n && u) {
						file_list[n] = u + "?start={start_bytes}";
					}
				}
			} else {
				api.sendEvent("model_error", "无法获取视频分段数据");
				return;
			}
			
			if (file_list.length) {
				var url:String = file_list[file_index];
				if (url) {
					//sina支持stream模式，自动开启
					api.item.stream = true;
					//更新播放地址
					api.item.src = url;
					api.item.url = url;
					//强制用video类型模块播放，免得多余的type设置不正确导致问题
					api.sendEvent("model_change", "video");
					return;
				}
			}
			//
			api.sendEvent("model_error", "无法获取视频播放地址");
		}
		
	}
	
}