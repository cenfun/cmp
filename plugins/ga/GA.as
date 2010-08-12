package {
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import com.google.analytics.*;

	public class GA extends MovieClip {

		private var tracker:AnalyticsTracker;
		private var api:Object;

		private var ga_id:String = "UA-56301-7";
		private var ga_debug:Boolean = false;
		
		private var url:String;

		public function GA() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			//init(this);
			url = root.loaderInfo.loaderURL;
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//用户操作事件跟踪
			var str:String = api.toString();
			var arr = str.match(/"\w+";/g);
			for (var i = 0; i < arr.length; i ++) {
				var s:String = arr[i];
				s = s.replace(/"|;/g, "");
				var a:Array = s.split("_");
				if (a.length == 2) {
					var t:String = a[0];
					if (t == "view" || t == "mixer" || t == "lrc" || t == "video" || t == "item") {
						api.addEventListener(apikey.key, s, eventHandler);
					}
				}
			}
			//开始对cmp跟踪统计
			init();
		}
		
		private function init():void {
			//读取自定义参数
			if (api.config.ga_debug) {
				//开启调试
				ga_debug = true;
			}
			if (api.config.ga_id) {
				//统计账户id
				ga_id = api.config.ga_id;
			}
			//
			tracker = new GATracker(api.cmp, ga_id, "AS3", ga_debug);
			//跟踪页面位置
			tracker.trackPageview(url);
		}
		
		//跟踪用户事件
		private function eventHandler(e):void {
			var type:String = "view";
			if (api.item) {
				type = api.item.type;
			}
			var action:String = e.type;
			var desc:String = url;
			if (api.item) {
				desc = api.item.label || api.item.src;
			}
			if (tracker) {
				tracker.trackEvent(type, action, desc);
			}
		}
	}

}