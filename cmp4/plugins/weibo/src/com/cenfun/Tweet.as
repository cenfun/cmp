package com.cenfun{

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;
	import flash.geom.*;

	public class Tweet extends MovieClip {
		public var tw:Number;
		public var th:Number;
		public var mc:MovieClip;
		public var xml:XML;
		public var img:Object;

		public var sheetText:StyleSheet = new StyleSheet();
		public var sheetInfo:StyleSheet = new StyleSheet();


		public function Tweet():void {
			sheetText.parseCSS("a { color:#A5DD37; } a:hover { text-decoration:underline; }");
			//sheetText.parseCSS("p { margin-left:0; } ");

			sheetInfo.parseCSS("a { color:#666666; } a:hover { color:#cccccc; text-decoration:underline; }");

			txt.addEventListener(TextEvent.LINK,linkClick);
			info.addEventListener(TextEvent.LINK,linkClick);
		}

		public function linkClick(e:TextEvent):void {
			if (! e.text) {
				return;
			}
			var w:Win = Win.win;
			var arr:Array = e.text.split(",");
			var cmd:String = arr.shift();
			var val:String = arr.join(",");
			if ((cmd == "del")) {
				//删除
				w.tweetDel(val);

			} else if ((cmd == "readd")) {
				//转播
				w.tweetReAdd(val);
			} else if ((cmd == "reply")) {
				//回复
				w.tweetReply(val);

			} else if ((cmd == "talk")) {

				w.userTalk(val);

			} else if ((cmd == "follow")) {

				w.userFollow(val);

			}
		}
		
		public function getThumb(xl:*):Object {
			var obj:Object;
			if (xl is XML || xl is XMLList) {
				var thumbnail:String = xl.thumbnail_pic;
				var bmiddle:String = xl.bmiddle_pic;
				var original:String = xl.original_pic;
				if (thumbnail) {
					obj = {
						thumbnail: thumbnail,
						bmiddle: bmiddle,
						original : original
					};
				}
			}
			return obj;
		}

		public function show(_xml:XML,_mc:MovieClip):void {
			xml = _xml;
			mc = _mc;
			if (! xml || ! mc) {
				return;
			}

			var username:String = xml.user.name;

			var link:String = Tools.getLink(xml.user);

			var str:String = '';

			str +=  '<font size="14" color="#999999">';
			str +=  '<a href="' + link + '" target="_blank"><b>' + xml.user.screen_name + '</b></a>';
			str +=  '</font>';

			if (Win.weibo_selfname != username) {
				str +=  '  <font color="#666666">';
				str +=  '<a href="event:follow,' + username + ',' + xml.user.id + '"><font color="#666666">关注</font></a> | ';
				str +=  '<a href="event:talk,' + username + '"><font color="#666666">对话</font></a>';
				str +=  '</font>';
			}

			str +=  '<br />';

			img = getThumb(xml);

			var val:String = xml.text;

			if (val) {
				str +=  Tools.weibo_format(val);
			}
			
			var retweet:XMLList = xml.retweeted_status;
			var isRetweet:Boolean = false;
			if (retweet is XMLList && retweet.length()) {
				isRetweet = true;
			}
			
			if (isRetweet) {

				var thumb:Object = getThumb(retweet);
				if (thumb) {
					img = thumb;
				}

				if (val) {
					str +=  '<br />';
				}

				str +=  '<font color="#aaaaaa">【转】</font>';
				
				var relink:String = Tools.getLink(retweet.user);
				
				str +=  '<a href="' + relink + '" target="_blank"><b>' + retweet.user.screen_name + '</b></a>：';

				var tt:String = retweet.text;
				
				str +=  Tools.weibo_format(tt);

			}


			str = Tools.rn(str);

			txt.wordWrap = true;
			txt.styleSheet = sheetText;
			txt.htmlText = str;

			txt.background = true;
			txt.backgroundColor = 0x222222;

			if (img) {
				//thumbnail bmiddle original
				var i:Image = new Image(img.thumbnail, 120, 120, img.original, false);
				image.addChild(i);
			}
			
			var ta:String = '<a href="http://api.t.sina.com.cn/'+xml.user.id+'/statuses/' + xml.id + '" target="_blank">';
			
			str = ta + Tools.timeago(xml.created_at) + '</a>  ';
			str +=  '来自' + Tools.rn(xml.source);
			str +=  '   <a href="event:readd,' + xml.id + '">转播</a>';
			str +=  '   <a href="event:reply,' + xml.id + '">评论</a>';

			if (Win.weibo_selfname == username) {

				str +=  '   <a href="event:del,' + xml.id + '">删除</a>';

			}

			info.wordWrap = true;
			info.styleSheet = sheetInfo;
			info.htmlText = str;

			//
			var head:String = xml.user.profile_image_url;
			var a:Image = new Image(head, 50, 50, link);
			avatar.addChild(a);

			if (isRetweet) {
				if (xml.user.name != retweet.user.name) {
					head = retweet.user.profile_image_url;
					var b:Image = new Image(head, 20, 20);
					b.mouseChildren = false;
					b.mouseEnabled = false;
					b.x = 30;
					b.y = 30;
					avatar.addChild(b);
				}
			}

		}

		public function resizeHandler(_tw:Number,_th:Number):void {

			tw = _tw;
			th = _th;

			layout();

		}

		public function layout():void {

			if (! mc || ! mc.numChildren) {
				return;
			}

			txt.width = tw - txt.x - 2;
			txt.autoSize = "left";

			var h:Number = txt.height;
			txt.autoSize = "none";
			txt.height = h + 1;

			if (img) {
				image.x = txt.x + 2;
				image.y = h + 5;
			}

			info.width = txt.width;
			info.autoSize = "left";

			if (img) {
				info.y = image.y + image.height;
			} else {
				info.y = txt.y + txt.height;
			}
			var i:int = mc.getChildIndex(this);

			if ((i > 0)) {

				var tweet:DisplayObject = mc.getChildAt((i - 1));
				if (tweet) {
					var t:Tweet = tweet as Tweet;
					y = t.y + t.height + 10;
				}

			} else {

				y = 0;

			}


		}


	}

}