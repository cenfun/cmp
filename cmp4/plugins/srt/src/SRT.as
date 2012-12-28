package {

	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.net.URLLoader;

	public class SRT extends MovieClip {
		public var api:Object;
		public var srt:String;
		public function SRT():void {
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
			//api.tools.output(this);

			api.addEventListener(apikey.key, 'lrc_load', loadHandler);
			//歌词数据加载完成事件
			api.addEventListener(apikey.key, 'lrc_loaded', loadedHandler, false, 100);
		}

		public function loadHandler(e:Object):void {
			srt = null;
		}

		public function loadedHandler(e:Object):void {
			
			if (! e.data || srt) {
				return;
			}
			
			var ba:ByteArray;
			if (e.data is ByteArray) {
				ba = e.data;
			} else {
				ba = api.win_list.lrc.text.loader.data;
			}
			
			//utf8 bom fix
			ba = api.tools.strings.bom(ba);
			
			var len:int = ba.length;
			if (len < 10) {
				return;
			}
			
			srt = ba.toString();
			
			var str:String;
			if (srt_check()) {
				str = srt_parse();
			}
			if (str) {
				//api.tools.output(str);
				e.stopImmediatePropagation();
				api.sendEvent("lrc_loaded", str);
			}

		}
		
		//srt解析======================================================================================
		public var srt_list:Array = [];
		public function srt_check():Boolean {
			srt_list = [];
			//=====================================
			srt = srt.replace(/^\s+/, '').replace(/\s+$/, '');
            var lst:Array = srt.split("\r\n\r\n");
            if(lst.length == 1) { 
				lst = srt.split("\n\n"); 
			}
			
			//api.tools.output(lst.join(""));
			//test================
			//lst.length = 30;
			//====================
			
            for (var i:int = 0; i < lst.length; i ++) {
                var line:Object = srt_line(lst[i]);
				if (line) {
					srt_list.push(line);
				}
            }
			
			//=====================================
			if (srt_list.length > 0) {
				return true;
			}
			return false;
		}
		
		public function srt_line(dat:String):Object {
            var arr:Array = dat.split("\r\n");
            if(arr.length == 1) { 
				arr = dat.split("\n"); 
			}
			if (arr.length > 2) {
				var line:Object = {
					index :  parseInt(arr[0]),
					start : "",
					end : "",
					text : ""
				};
				//time
                var idx:Number = arr[1].indexOf(' --> ');
                if(idx > 0) {
                    line.start = formatTime(arr[1].substr(0, idx));
                    line.end = formatTime(arr[1].substr(idx + 5));
                }
                //text
                if(arr[2]) {
                    var text:String = arr[2];
                    for (var i:int = 3; i < arr.length; i++) {
                        text += ' ' + arr[i];
                    }
					line.text = text;
                }
				return line;
            }
			return null;
        }
		
		public function srt_parse():String {
			
			var arr:Array = [];
			for (var i:int = 0; i < srt_list.length; i ++) {
				var line:Object = srt_list[i];
				//api.tools.output(line.index, line.start, line.end, line.text);
				
				//解析成lrc需要的时间格式
				var ts:Array = line.start.split(":");
				var sec:Number = parseFloat(ts.pop());
				var min:Number = parseInt(ts.pop());
				if (ts.length) {
					min += parseInt(ts.pop()) * 60;
				}
				
				var str:String = "["+ (min + ":" + sec) + "]" + line.text;
				arr.push(str);
				
			}
			
			return arr.join("\r\n");
			
			
			
			/*
			//kmc格式性能太低，还是采用上面的lrc格式
			var xml:XML = new XML("<kmc></kmc>");
			
			for (var i:int = 0; i < srt_list.length; i ++) {
				var line:Object = srt_list[i];
				//api.tools.output(line.index, line.start, line.end, line.text);
				
				var str:String = "<l t=\""+ line.start + "," + line.end + "\">" + line.text + "</l>";
				var child:XML = new XML(str);
				xml.appendChild(child);
				
			}
			
			return xml.toXMLString();
			*/
		}
		
		
		
		//=============================================================================================
		public function formatTime(str:String):String {
			str = str.replace(',', '.');
			
			return str;
		}
		
		
	}

}