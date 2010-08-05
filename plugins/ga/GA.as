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

		public function GA() {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			//init(this);
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//用户操作跟踪
			//播放项相关事件
			var evts_item:Array = [
			"view_item",
			"view_mute",
			"view_next",
			"view_play",
			"view_prev",
			"view_progress",
			"view_stop",
			"view_volume",
			"mixer_color",
			"mixer_displace",
			"mixer_filter",
			"mixer_next",
			"mixer_prev",
			"lrc_resize",
			"video_resize",
			"video_effect",
			"video_smoothing",
			];
			//其他界面操作事件
			var evts_view:Array = [
			"view_console",
			"view_fullscreen",
			"view_list",
			"view_lrc",
			"view_option",
			"view_random",
			"view_repeat",
			"view_video",
			"skin_change",
			"video_max",
			"lrc_max"
			];
			var type:String;
			for each(type in evts_item) {
				api.addEventListener(apikey.key, type, itemHandler);
			}
			for each(type in evts_view) {
				api.addEventListener(apikey.key, type, viewHandler);
			}
			api.addEventListener(apikey.key, "item_deleted", delHandler);
			
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
			tracker.trackPageview( "/cmp");

		}
		
		//跟踪用户事件
		private function itemHandler(e):void {
			var type:String = "view";
			if (api.item) {
				type = api.item.type;
			}
			var action:String = e.type;
			var desc:String = "";
			if (api.item) {
				desc = api.item.label || api.item.src;
			}
			track(type, action, desc);
		}
		private function viewHandler(e):void {
			var type:String = "view";
			var action:String = e.type;
			var desc:String = "";
			track(type, action, desc);
		}
		private function delHandler(e):void {
			var type:String = e.data.type || "view";
			var action:String = e.type;
			var desc:String = e.data.label;
			track(type, action, desc);
		}
		private function track(type:String, action:String, desc:String):void {
			if (tracker) {
				tracker.trackEvent(type, action, desc);
			}
		}
	}

}