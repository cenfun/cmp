package {

	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.net.*;
	import flash.net.URLLoader;

	public class KMC extends MovieClip {
		public var api:Object;
		public var kmc:String;
		public function KMC():void {
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

			api.addEventListener(apikey.key, 'lrc_load', loadHandler);
			//歌词数据加载完成事件
			api.addEventListener(apikey.key, 'lrc_loaded', loadedHandler, false, 100);
		}

		public function loadHandler(e:Object):void {
			kmc = null;
		}

		public function loadedHandler(e:Object):void {
			//api.tools.output(e.data);
			if (! e.data || kmc) {
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
			
			kmc = ba.toString();
			//api.tools.output(kmc);
			
			var str:String;
			if (ksc_check()) {
				//ksc检测
				str = ksc_parse();
			} else if (qrc_check()) {
				//qrc检测
				str = qrc_parse();
			}
			
			if (str) {
				e.stopImmediatePropagation();
				api.sendEvent("lrc_loaded", str);
			}

		}
		
		//ksc解析======================================================================================
		public var ksc_reg:RegExp = /karaoke\.add\('([^']+)', '([^']+)', '([^']+)', '([^']+)'\);/ig;
		public var ksc_list:Array;
		public function ksc_check():Boolean {
			ksc_list = [];
			ksc_list = kmc.match(ksc_reg);
			if (ksc_list.length > 0) {
				return true;
			}
			return false;
		}
		
		public function ksc_parse():String {
			var str:Array = [];
			
			var ti:String = str_cut(kmc, "karaoke.songname := '", "';");
			if (!ti) {
				ti = str_cut(kmc, "karaoke.tag('歌名', '", "');");
			}
			if (ti) {
				ti = xml_attr(ti);
			}
			//api.tools.output(ti);
			
			var ar:String = str_cut(kmc, "karaoke.singer := '", "';");
			
			if (!ar) {
				ar = str_cut(kmc, "karaoke.tag('歌手', '", "');");
			}
			if (ar) {
				ar = xml_attr(ar);
			}
			//api.tools.output(ar);
			
			str.push('<kmc ti="' + ti + '" ar="' + ar + '" al="" by="" offset="0" duration="">');
			
			var len:int = ksc_list.length;
			//api.tools.output(len);
			for (var i:int = 0; i < len; i ++) {
				ksc_reg.lastIndex = 0;
				var arr:Array = ksc_reg.exec(ksc_list[i]);
				if (arr && arr.length) {
					str.push('<l t="' + arr[1] + ',' + arr[2] + ',' + arr[4] + '">' + arr[3] + '</l>');
				}
			}
			
			str.push('</kmc>');
			
			return str.join("");
			
		}
		
		
		//qrc解析======================================================================================
		public function qrc_check():Boolean {
			var str:String = str_cut(kmc, "<QrcInfos>", "</QrcInfos>");
			if (str) {
				return true;
			}
			return false;
		}
		
		public function qrc_parse():String {
			var xl:XMLList;
			try {
				xl = new XMLList(kmc);
			} catch (e:Error) {
				return kmc;
			}
			if (xl) {
				var LyricContent:String = xl..@LyricContent;
				if (LyricContent) {
					return parseQrc(LyricContent);
				}
			}
			return kmc;
		}
		
		private var list:Array;
		private var split:String = "{|}";
		private var reg_tabo:RegExp = /\[(ti|ar|al|by|offset|total):(.+)\]\s+/ig;
		private var reg_line:RegExp = /(\[(\d+),(\d+)\])(.+)\s+/ig;
		private var reg_word:RegExp = /([^\(]*)\((\d+),(\d+)\)/ig;
		public function parseQrc(qrc:String):String {
			var lrc_str:String = qrc;
			//使正则能匹配到最后一行
			lrc_str +=  "\n";
			//取得歌词资料
			var taboList:Array = lrc_str.match(reg_tabo);
			var tags:Array = [];
			for each (var tabo:String in taboList) {
				var str:String = tabo.replace(reg_tabo,setTabo);
				if (str) {
					tags.push(str);
				}
			}
			
			var xml:XML = new XML("<kmc "+tags.join(" ")+"></kmc>");

			//新歌词列表
			list = [];
			//取得歌词行
			lrc_str.replace(reg_line, setLine);
			if (list.length) {
				//按时间排序数组
				for (var i:int = 0; i < list.length; i ++) {
					var obj:Object = list[i];
					var line:String = "<l t=\""+ obj.start + "," + obj.end + "," + obj.time +"\">" + obj.text + "</l>";
					var child:XML = new XML(line);
					xml.appendChild(child);
				}
			}
			//
			
			var val:String = xml.toXMLString();
			//api.tools.output(val);
			
			return val;

		}

		private function setTabo():String {
			var a1:String = arguments[1];
			var a2:String = arguments[2];
			if (a1 == "duration") {
				a2 = formatTime(parseInt(a2));
			} else {
				a2 = xml_attr(a2);
			}
			return a1 + "=\"" + a2 + "\"";
		}

		private function setLine():String {
			var start:Number = parseInt(arguments[2]);
			var length:Number = parseInt(arguments[3]);
			var end:Number = start + length;
			var line:String = arguments[4];
			var str:String = line.replace(reg_word,parseTail);
			var arr:Array = str.split(split);
			var text:String = "";
			var time:Array = [];
			for (var i:int = 0; i < arr.length - 1; i = i + 2) {
				time.push(arr[i]);
				text +=  arr[i + 1];
			}
			list.push({start:formatTime(start, true), end:formatTime(end, true), text:text, time:time.join(",")});
			return "";
		}

		private function parseTail():String {
			var length:int = parseInt(arguments[3]);
			var str:String = arguments[1];
			if (str.length > 1) {
				str = "[" + str + "]";
			}
			return length + split + str + split;
		}

		private function getDuration(str:String):int {
			var arr:Array = str.split(/\s*\:\s*/);
			var max:int = arr.length;
			var kms:Number = 0;
			while (arr.length) {
				var v:Number = parseFloat(arr.pop());
				if (! isNaN(v)) {
					kms +=  v * Math.pow(60,max - arr.length - 1);
				}
			}
			kms = int(kms * 1000);
			return kms;
		}
		
		//=============================================================================================
		public function formatTime(km:Number, db:Boolean = false):String {
			var str:String = "";
			var mm:Number = km / 1000;
			var m:int = int(mm);
			str = zero(m/60) + ":" + zero(m%60);
			if (db) {
				var ms:String = mm.toString();
				str +=  ms.substr(ms.indexOf("."));
			}
			return str;
		}
		public function zero(n:Number):String {
			var str:String = String(int(n));
			if (str.length < 2) {
				str = "0" + str;
			}
			return str;
		}
		
		
		public function xml_attr(str:String):String {
			str = str.replace(/</g, "&lt;");
			str = str.replace(/>/g, "&gt;");
			str = str.replace(/"/g, "&quot;");
			str = str.replace(/@/g, "&amp;");
			return str;
		}
		public function str_cut(str:String, s1:String, s2:String):String {
			var val:String = "";
			if (str) {
				var i1:int = str.indexOf(s1);
				if (i1 == -1) {
					return "";
				}
				str = str.substr(i1 + s1.length);
				//
				var i2:int = str.indexOf(s2);
				if (i2 == -1) {
					return ""
				}
				str = str.substr(0, i2);
				val = str;
			}
			return val;
		}
		
		
	}

}