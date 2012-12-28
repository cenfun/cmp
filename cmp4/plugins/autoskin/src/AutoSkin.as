package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	public class AutoSkin extends MovieClip {
		public var old_id:int;
		//cmp的api接口
		public var api:Object;
		
		public function AutoSkin() {
			
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);

		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			
		}
		
		public function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//媒体加载时调用
			api.addEventListener(apikey.key, "control_load", skinHandler);
			//记住原始皮肤id
			old_id = api.config.skin_id;
		}

		public function skinHandler(e:Event):void {
			//读取当前项设置的皮肤id，没有就使用旧的id
			var skin_id:int = api.item.skin_id || old_id;
			//如果和当前皮肤不相等，就修改皮肤id，并发送皮肤改变事件
			if (skin_id != api.config.skin_id) {
				api.config.skin_id = skin_id;
				api.sendEvent("skin_change");
			}
	
		}
		
		
	}
	
}
