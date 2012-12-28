package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;

	public class Srcs extends MovieClip {
		public var api:Object;
		public function Srcs():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
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
			
			//错误事件
			api.addEventListener(apikey.key, 'model_error', errorHandler, false, 100);
			
			//加载事件
			api.addEventListener(apikey.key, 'model_load', loadHandler, false, 100);
			
		}

		private function errorHandler(e:Event):void {
			//不存在多地址，直接跳过
			if (!api.item.srcs_list) {
				return;
			}
			//如果还没有全部播放完成
			if (api.item.srcs_list.length) {
				//停止默认事件
				e.stopImmediatePropagation();
				//选择下一个地址进行播放
				start();
			}
		}
		
		private function loadHandler(e:Event = null):void {
			var url:String = api.item.url;
			var arr:Array = api.tools.strings.array(url);
			if (arr.length > 1) {
				//停止默认事件
				e.stopImmediatePropagation();
				//存在多地址，保存到项数组
				api.item.srcs_list = arr;
				//多地址时不重连
				api.item.reload = true;
				
				//开始队列播放
				start();
			}
		}
		
		public function start():void {
			if (api.item.srcs_list.length) {
				//从列表取出一个地址
				var url:String = api.item.srcs_list.shift();
				//api.tools.output(url);
				//更新播放地址
				api.item.url = url;
				//通知cmp模块加载
				api.sendEvent("model_load");
			} else {
				//全部尝试完成，都无法播放
				api.sendEvent("model_error", "地址都无法播放");
			}
		}
		
		
	}
	
}