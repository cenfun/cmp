package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	public class History extends MovieClip {
		private var api:Object;
		
		private var history:XML;
		private var xml:XMLList;
		
		private var history_label:String = "播放历史";
		private var history_position:int = 1;
		private var history_max:int = 10;
		
		private var cookie:SharedObject;
		
		public function History() {
			
			try {
				cookie = SharedObject.getLocal("cmp_history_list_data");
			} catch(e:Error) {
				return;
			}
			
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
		}


		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			api.addEventListener(apikey.key, "model_start", startHandler);
			api.addEventListener(apikey.key, "item_deleted", delHandler);
			//
			history_label = api.config.history_label || history_label;
			history_position = parseInt(api.config.history_position) || history_position;
			history_max = parseInt(api.config.history_max) || history_max;
			//
			history = <m></m>;
			//
			try {
				xml = new XMLList(cookie.data.xml);
			} catch (e:Error) {
			}
			if (xml is XMLList) {
				var len:int = xml.length();
				if (len) {
					history_label += "(" + len + ")";
					history.@label = history_label;
					history.appendChild(xml);
					var cmp_list:XML = api.list_xml as XML;
					var child:XML = cmp_list.children()[history_position - 1];
					if (child) {
						cmp_list.insertChildBefore(child, history);
					} else {
						cmp_list.appendChild(history);
					}
					api.sendEvent("list_loaded");
				}
			}
		}
		
		private function delHandler(e:Object):void {
			var item:Object = e.data;
			//api.tools.output(item.label);
			if (history_label == item.label) {
				cookie.data.xml = "";
			}
		}
		

		private function startHandler(e:Event = null):void {
			history.prependChild(api.item.xml);
			var list:XMLList = history.children();
			var len:int = list.length();
			if (len > history_max) {
				len = history_max;
			}
			var str:String = "";
			for (var i:int = 0; i < len; i ++) {
				str += list[i].toXMLString()
			}
			cookie.data.xml = str;
		}


	}

}