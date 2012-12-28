package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	import com.adobe.serialization.json.*;
	
	public class Xiu56 extends MovieClip {
		public var api:Object;
		public var json:Object;
		public var config:Object = {
			opened : "",
			label : "秀56美女直播",
			istop : true,
			refresh : true,
			refresh_time : 60,
			livelist : "http://xiu.56.com/api/liveListv3.php?page=1&rows=100",
			userapi : "http://xiu.56.com/api/userFlvApi.php?room_user_id="
		};
		
		public var xml:XML;
		
		public function Xiu56():void {
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
			//xiu56 代理
			api.addProxy("xiu56", callback);
			
			//自动加载xiu56美女列表
			
			for (var k:String in config) {
				var key:String = "xiu56_" + k;
				if (api.config.hasOwnProperty(key)) {
					config[k] = api.config[key];
				}
			}
			if (!config.refresh_time || config.refresh_time < 10) {
				config.refresh_time = 10;
			}
			
			if (!config.livelist) {
				return;
			}
			
			//
			xml = <m/>;
			
			xml.@label = config.label;
			xml.@opened = config.opened;
			
			if (config.istop) {
				api.list_xml.prependChild(xml);
			} else {
				api.list_xml.appendChild(xml);
			}
			
			loadJSON();
			
		}
		
		//加载地址配置
		public function loadJSON():void {
			
			//加载文件信息
			var url:String = config.livelist + "&t=" + Math.random();
			
			var req:URLRequest = new URLRequest(url);
			new MyLoader(req, listError, listProgress, listComplete);
			
		}
		private function listProgress(ebl:uint, ebt:uint):void {
			var str:String =  "";
			if (ebt) {
				str = Math.round(100 * ebl / ebt) + "%";
			}
		}
		
		public function listError(msg:String):void {
			api.tools.output("加载xiu56房间列表失败");
			refresh();
		}
		//信息加载完成
		public function listComplete(ba:ByteArray):void {
			var str:String = String(ba);
			//api.tools.output(str);
			json = JSON.decode(str);
			if (!json) {
				listError("返回数据格式错误");
				return;
			}
			var list:Array = [];
			if (typeof(json.roomArray) == "array") {
				list = json.roomArray;
			} else {
				for (var k:String in json.roomArray) {
					list = list.concat(json.roomArray[k]);
				}
			}
			//按人气排序
			list.sortOn("count", Array.NUMERIC);
			list.reverse();
			
			//使用第一个做目录图片
			xml.@image = list[0].room_img;
			//
			var xl:XML = <list />;
			for (var i:int = 0; i < list.length; i ++) {
				xl.appendChild(getRoom(list[i]));
			}
			xml.setChildren(xl.children());
			
			api.sendEvent("list_loaded");
			
			refresh();
			
		}
		
		public function refresh():void {
			if (config.refresh) {
				setTimeout(loadJSON, config.refresh_time * 1000);
			}
		}
		
		public function getRoom(d:Object):XML {
			var xml:XML = <m/>;
			
			for (var k:String in d) {
				xml.@[k] = d[k];
			}
			xml.@type = "video";
			var label:String = "";
			if (d.hifi == "1") {
				label += "[高清] ";
			}
			label += d.nickname + "(" + d.count + ")";
			xml.@label = label;
			xml.@text = "开播：" + d.starttime;
			xml.@image = d.room_img;
			xml.@roomid = d.roomid;
			xml.@user_id = d.user_id;
			xml.@src = "proxy:xiu56," + d.user_id;
			return xml;
		}
		
		
		public function callback(id:String, ...rest):void {
			if (!id) {
				api.sendEvent("model_error", "没有代理函数的参数值");
				return;
			}
			
			//api.tools.output(id);
			
			api.sendState("connecting");
			
			//
			//加载文件信息
			var url:String = config.userapi + id;
			var req:URLRequest = new URLRequest(url);
			new MyLoader(req, userError, userProgress, userComplete);
			
			
		}
		private function userProgress(ebl:uint, ebt:uint):void {
			var str:String =  "";
			if (ebt) {
				str = Math.round(100 * ebl / ebt) + "%";
			}
		}
		
		public function userError(msg:String):void {
			api.tools.output(msg);
		}
		//信息加载完成
		public function userComplete(ba:ByteArray):void {
			var str:String = String(ba);
			
			var vars:URLVariables = new URLVariables(str);
			
			//api.tools.output(vars);
			//for (var k:String in vars) {
				//api.tools.output(k + "=" + vars[k]);
			//}
			
			//token=vff2f22c7859cab13841ff055b0292aa5
			//host=play.xiu.v-56.com
			//proxy_type=rtmp
			//flv_path=http://xiu.56.com/vshow2?token=vff2f22c7859cab13841ff055b0292aa5
			//status=1
			
			var token:String = vars["token"];
			
			if (token && token.length > 1) {
				
				api.item.rtmp = "rtmp://play.xiu.v-56.com/vshow";
				api.item.src = token;
				api.item.url = token;
			
				//强制用video类型模块播放，免得多余的type设置不正确导致问题
				api.sendEvent("model_change", "video");
				return;
			}
			
			api.sendEvent("model_error", "直播未开始");
			
		}
		
	}
	
}