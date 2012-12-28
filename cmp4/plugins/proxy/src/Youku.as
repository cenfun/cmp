package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	import com.adobe.serialization.json.*;
	
	
	public class Youku extends Object {
		public var api:Object;
		private var url_playlist:String = "http://v.youku.com/player/getPlayList/VideoIDS/";
		private var url_flvpath:String = "http://f.youku.com/player/getFlvPath/sid/";
		
		//当前播放文件
		private var file:Object;
		//当前地址列表
		private var file_list:Array;
		//第几段，youku默认从0开始
		private var file_index:int = 0;
		//默认视频格式类型
		private var file_type:String = "flv";
		
		
		private var ReportSID:String;
		
		public function Youku(_api:Object):void {
			api = _api;
			//时间值
			ReportSID = new Date().getTime() + "" + (1000 + new Date().getMilliseconds()) + "" + (int(Math.random() * 9000) + 1000);
		}
		
		public function callback(vids:String, index:int = 0, type:String = "flv", ...rest):void {
			if (!vids) {
				api.sendEvent("model_error", "没有代理函数的参数值");
				return;
			}
			file_index = index;
			file_type = type;
			//api.tools.output(vids, index, type);
			api.sendState("connecting");
			load(vids);
		}
		
		private function load(vids:String):void {
			var url:String = url_playlist + vids + "/timezone/+08/version/5/source/out";
			
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
			var str:String = e.target.data.toString();
			//trace(str);
			var json:Object = JSON.decode(str);
			parse(json);
		}
		
		private function parse(json:Object):void {
			var arr:Array = json.data;
			//
			file = arr[0];
			//计算所有分段地址列表
			file_list = [];
			//
			//分段
			var segs:Array;
			if (file_type == "flv" && file.segs.hasOwnProperty("flv")) {
				segs = file.segs.flv;
			} else if (file.segs.hasOwnProperty("mp4")) {
				file_type = "mp4";
				segs = file.segs.mp4;
			}
			if (segs is Array) {
				//解码种子
				var seed:Number = parseInt(file.seed);
				//根据类型选择，flv为普通，mp4为清晰
				var fileid:String = file.streamfileids[file_type];
				//计算key值
				var key1:String = (Number("0x" + file.key1) ^ Number("0xA55AA5A5")).toString(16);
            	var key2:String = file.key2;
				var key:String = key2 + key1;
				
				for each(var seg:Object in segs) {
					makeUrl(seg, seed, fileid, key);
				}
			} else {
				api.sendEvent("model_error", "无法获取视频分段数据");
				return;
			}
			
			if (file_list.length) {
				var url:String = file_list[file_index];
				if (url) {
					//youku支持stream模式，自动开启
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
		
		private function makeUrl(seg:Object, seed:Number, fileid:String, key:String):void {
			//获取第几段
			var no:int = parseInt(seg.no);
			
			var ns:String = no.toString(16).toUpperCase();
			if (ns.length < 2) {
				ns = "0" + ns;
			}
			//计算解码串
			var cg_str:String = cg_hun(seed);
			//计算视频fileid
			fileid = cg_fun(fileid, cg_str);
			
			var s8:String = fileid.substr(0, 8);
			var s10:String = fileid.substr(10);
			fileid = s8 + ns + s10;
			
			var ts:String = seg.seconds;
			
			var K:String = key;
			if (seg.k) {
				K = seg.k;
			}
			//合成请求url
			var url:String = url_flvpath + ReportSID + "_" + ns + "/st/" + file_type + "/fileid/" + fileid + "?" + "start={start_seconds}&K=" + K + "&myp=0&ts=" + ts;
			
			file_list[no] = url;
			//api.tools.output(url);
		}
		
		private function random(input:Number):Number {
			return Math.round(input * Math.random());
		}
		
		private function cg_fun(b:String, val:String):String {
            var arr:Array = b.split("*");
			arr.length = 66;
            var str:String = "";
			for (var i:int = 0; i < arr.length; i ++) {
				var n:int = parseInt(arr[i]);
				var c:String = val.charAt(n);
                str += c;
            }
            return str;
        }
		
		private function cg_hun(seed:Number):String {
            var val:String = "";
            var str:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ/\\:._-1234567890";
            var len:int = str.length;
           	for (var i:int = 0; i < len; i ++) {
				seed = ((seed * 211) + 30031) % 65536;
                var n:int = int(seed / 65536 * str.length);
				//trace(n, str.length)
				var c:String = str.charAt(n);
                val += c;
                str = str.replace(c, "");
            }
			return val;
        }
		
	}
	
}