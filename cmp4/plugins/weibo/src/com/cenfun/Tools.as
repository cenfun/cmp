package com.cenfun{

	import flash.display.*;

	public class Tools {

		public static function clear(clip:DisplayObjectContainer):void {
			if (! clip) {
				return;
			}
			while (clip.numChildren) {
				clip.removeChildAt(0);
			}
		}

		public static function rn(str:String):String {
			return str.replace(/\r|\n/ig, "");
		}

		public static function num_format(num:Number):String {
			var arr:Array = num.toString().split(".");
			var str:String = arr[0];
			if (str.length > 3) {
				var a:Array = [];
				var s:String;
				var p:int;
				while (str.length > 3) {
					p = str.length - 3;
					s = str.substr(p);
					a.unshift(s);
					str = str.substr(0,p);
				}
				a.unshift(str);
				s = a.join(",");
				arr[0] = s;
			}
			return arr.join(".");
		}
		
		public static function weibo_format(str:String):String {
			str = "" + str;
			
			var reg:RegExp = new RegExp('#([^\s]+)#', "ig");
			str = str.replace(reg, '<a href="http://weibo.com/k/%2523$1%2523" target="_blank">#$1#</a>');
			
			reg = new RegExp('((http://t\\.cn|http://sinaurl\\.cn)/([0-9a-z]{6}))','ig');
			str = str.replace(reg, '<a href="$1" target="_blank">$1</a>');
			
			reg = new RegExp('@([0-9a-z\u4e00-\u9fa5]+)', "ig");
			str = str.replace(reg, '<a href="http://weibo.com/n/$1" target="_blank">@$1</a>');
			return str;
		}
		
		//用户名如果有中文就换id
		public static function getLink(xl:*):String {
			var str:String = "";
			if (xl is XML || xl is XMLList) {
				var dm:String = xl.domain;
				var id:String = xl.id;
				if (dm) {
					str = dm;
				} else {
					str = id;
				}
			}
			return "http://weibo.com/" + str;
		}

		public static function timeago(timestamp:String):String {
			var D:Date = new Date();
			var num:Number = Math.round(Date.parse(timestamp) * 0.001);
			var now:Number = Math.round(D.time * 0.001);
			var sec:Number = now - num;
			if (sec < 60) {
				return "刚刚";
			} else if (sec < 3600) {
				return Math.round(sec / 60) + "分钟以前";
			} else if (sec < 3600 * 12) {
				return Math.round(sec / 3600) + "小时以前";
			} else {
				var date:Date = new Date();
				date.time = num * 1000;

				var str:String = "";

				var Y:Date = new Date();
				Y.time = D.time - 1000 * 60 * 60 * 24;

				if (date.fullYear == D.fullYear && date.month == D.month && date.date == D.date) {
					str +=  "今天";
				} else if (date.fullYear == Y.fullYear && date.month == Y.month && date.date == Y.date) {
					str +=  "昨天";
				} else {
					if (date.fullYear != D.fullYear) {
						str +=  date.fullYear + "年";
					}
					str += (date.month + 1) + "月";
					str +=  date.date + "日 ";
				}

				str +=  zero(date.hours) + ":" + zero(date.minutes);

				return str;
			}


		}

		public static function zero(n:Number):String {
			var str:String = String(int(n));
			if (str.length < 2) {
				str = "0" + str;
			}
			return str;
		}

		public static function trim(input:String):String {
			return ltrim(rtrim(input));
		}
		public static function ltrim(input:String):String {
			var size:Number = input.length;
			for (var i:Number = 0; i < size; i++) {
				if (input.charCodeAt(i) > 32) {
					return input.substring(i);
				}
			}
			return "";
		}
		public static function rtrim(input:String):String {
			var size:Number = input.length;
			for (var i:Number = size; i > 0; i--) {
				if (input.charCodeAt(i - 1) > 32) {
					return input.substring(0, i);
				}
			}

			return "";
		}

	}

}