package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	
	import com.adobe.serialization.json.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.net.URLLoader;
	
	
	public class Youku extends MovieClip {
		public var api:Object;
		public var tw:Number;
		public var th:Number;
		
		private var url_playlist:String = "http://v.youku.com/player/getPlayList/VideoIDS/";
		private var url_flvpath:String = "http://f.youku.com/player/getFlvPath/sid/";
		
		//当前播放文件
		private var file:Object;
		//当前地址列表
		private var file_list:Array;
		//第几段
		private var file_index:int = 0;
		//默认视频格式类型
		private var file_type:String = "flv";
		
		
		private var ReportSID:String;
		
		public function Youku():void {
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
			
			if (!api.hasOwnProperty("addProxy")) {
				var tf:TextField = new TextField();
				tf.autoSize = "left";
				tf.defaultTextFormat = new TextFormat(null, 12, 0xff0000, true);
				tf.htmlText = '<a href="http://cmp.cenfun.com/download/cmp4">当前版本CMP4不支持此插件，请点击下载并升级到最新版</a>';
				addChild(tf);
				return;
			}
			//时间值
			ReportSID = new Date().getTime() + "" + (1000 + new Date().getMilliseconds()) + "" + (random(9000) + 1000);
			//添加自定义代理函数，这里是优酷解析函数
			//名称为youku，这样需要用的协议格式为：proxy:youku,参数值
			//以下则表示proxy协议中，如果是youku名称的代理函数，则使用这里的yk_callback函数进行处理
			api.addProxy("youku", yk_callback);
		}
		
		
		public function yk_callback(vids:String, index:int = 0, type:String = "flv"):void {
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

		/*
		2011.1.17 youku视频数据结构
		
		以后youku更新结构需更新本插件算法
		
		http://player.youku.com/player.php/sid/XMjM2OTE0NTIw/v.swf
		
		{
			"data":[{
				"tt":"0","ct":"u","cs":"2146",
				"logo":"http:\/\/g2.ykimg.com\/1100641F464D30220136A6019C3C1CED3F2CF9-4B46-A6AA-AF12-4E55814FC908",
				"seed":5052,
				"tags":["\u5468\u97e6\u5f64"],
				"categories":"86",
				"videoid":"59228630",
				"vidEncoded":"XMjM2OTE0NTIw",
				"username":"\u4f18\u9177\u5a31\u4e50",
				"userid":"27016220",
				"title":"\u5468\u97e6\u5f64\u65e5\u672c\u5199\u771f\u5168\u7a0b\u8bb0\u5f55 \u6cf3\u88c5\u518d\u5c55\u50b2\u4eba\u8eab\u6750\u5168",
				"key1":"b341d68b",
				"key2":"ac2a2f5f53665728",
				"seconds":"4395.82",
				"streamfileids":{
					"mp4":"63*10*63*63*63*20*63*29*63*63*18*19*10*63*18*62*28*30*11*28*18*28*63*8*56*48*10*48*8*48*19*29*48*11*63*29*28*19*14*37*10*30*53*14*29*48*10*18*14*20*37*37*61*14*56*62*30*53*30*63*53*62*8*53*37*20*",
					"flv":"63*10*63*63*63*61*63*29*63*63*18*19*10*63*61*61*63*8*11*28*18*28*63*8*56*48*10*48*8*48*19*29*48*11*63*29*28*19*14*37*10*30*53*14*29*48*10*18*14*20*37*37*61*14*56*62*30*53*30*63*53*62*8*53*37*20*"
					},
				"segs":{
					"mp4":[
						{"no":"0","size":"30716298","seconds":"422"},
						{"no":"1","size":"25425850","seconds":"425"},
						{"no":"2","size":"24202596","seconds":"422"},
						{"no":"3","size":"23136621","seconds":"421"},
						{"no":"4","size":"26059530","seconds":"426"},
						{"no":"5","size":"25832961","seconds":"423"},
						{"no":"6","size":"21587984","seconds":"425"},
						{"no":"7","size":"37696866","seconds":"422"},
						{"no":"8","size":"21016093","seconds":"425"},
						{"no":"9","size":"26676776","seconds":"420"},
						{"no":"10","size":"14051362","seconds":"165"}],
					"flv":[
						{"no":"0","size":"13467710","seconds":"423"},
						{"no":"1","size":"13467339","seconds":"426"},
						{"no":"2","size":"14109861","seconds":"425"},
						{"no":"3","size":"11928427","seconds":"422"},
						{"no":"4","size":"15704035","seconds":"422"},
						{"no":"5","size":"12213776","seconds":"426"},
						{"no":"6","size":"13071672","seconds":"423"},
						{"no":"7","size":"14967411","seconds":"426"},
						{"no":"8","size":"11696724","seconds":"424"},
						{"no":"9","size":"14434092","seconds":"422"},
						{"no":"10","size":"6186276","seconds":"157"}]
						},
				"streamsizes":{"mp4":"276402937","flv":"141247323"},
				"streamtypes":["flvhd","mp4"],
				"streamtypes_o":["flvhd","mp4"]
				}],
		
		"user":{"id":"77129471"},
		"controller":{"search_count":true,"mp4_restrict":1,"stream_mode":2,"share_disabled":false,"download_disabled":false,"continuous":0}
		}
		
		http://f.youku.com/player/getFlvPath/sid/129525040214011401237_00/st/mp4/fileid/0300080B004D304A6FE646019C3C1CDBCE0B6D-73F5-BC34-8772-9AF5F05A1578?K=e47590868d3b4ec718266e0e&myp=0&ts=422
		http://f.youku.com/player/getFlvPath/sid/129525040214011401237_00/st/mp4/fileid/0300080B004D304A6FE646019C3C1CDBCE0B6D-73F5-BC34-8772-9AF5F05A1578?start=170&K=e47590868d3b4ec718266e0e&myp=0&ts=422
		http://f.youku.com/player/getFlvPath/sid/129525040214011401237_01/st/mp4/fileid/0300080B014D304A6FE646019C3C1CDBCE0B6D-73F5-BC34-8772-9AF5F05A1578?start=332&K=e47590868d3b4ec718266e0e&myp=0&ts=425
		http://f.youku.com/player/getFlvPath/sid/129525040214011401237_03/st/mp4/fileid/0300080B034D304A6FE646019C3C1CDBCE0B6D-73F5-BC34-8772-9AF5F05A1578?start=6&K=e47590868d3b4ec718266e0e&myp=0&ts=421
		
		*/
		
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
			
			//合成请求url
			var url:String = url_flvpath + ReportSID + "_" + ns + "/st/" + file_type + "/fileid/" + fileid + "?" + "start={start_seconds}&K=" + key + "&myp=0&ts=" + ts;
			
			file_list[no] = url;
			//api.tools.output(url);
		}

		//解码函数========================================================================================
		
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