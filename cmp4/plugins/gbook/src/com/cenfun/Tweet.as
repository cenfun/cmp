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
		public var img:String;
		
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
			if (!e.text) {
				return;
			}
			var w:Win = Win.win;
			var arr:Array = e.text.split(",");
			var cmd:String = arr[0];
			var val:String = arr[1];
			if (cmd == "del") {
				//删除
				w.tweetDel(val);
				
			} else if (cmd == "readd") {
				//转播
				w.tweetReAdd(val);
			} else if (cmd == "reply") {
				//回复
				w.tweetReply(val);
				
			} else if (cmd == "talk") {
				
				w.userTalk(val);
				
			} else if (cmd == "follow") {
				
				w.userFollow(val);
				
			}
		}
		
		/*
		<info>
      	<city_code/>
      	<count>861</count>
      	<country_code>1</country_code>
      	<from>网页</from>
      	<fromurl>网页</fromurl>
      	<geo>0</geo>
      	<head>http://app.qlogo.cn/mbloghead/a1407d65cc66644423d0</head>
      	<id>8553078139402</id>
      	<image>http://app.qpic.cn/mblogpic/6fa63ca1e230d499feca</image>
      	<isvip>1</isvip>
      	<location>福建</location>
      	<mcount>48</mcount>
      	<name>lengxiaohua</name>
      	<nick>冷笑话精选</nick>
      	<origtext>弟弟买了个名牌，得瑟得很。。。</origtext>
      	<province_code>35</province_code>
      	<self>0</self>
      	<source/>
      	<status>0</status>
      	<text>弟弟买了个名牌，得瑟得很。。。</text>
      	<timestamp>1299757426</timestamp>
      	<type>1</type>
    	</info>
		*/
		
		public function show(_xml:XML, _mc:MovieClip):void {
			xml = _xml;
			mc = _mc;
			if (!xml || !mc) {
				return;
			}
			
			var username:String = xml.name;
			var link:String = "http://t.qq.com/" + username;
			
			var str:String = '';
			
			str += '<font size="14" color="#999999" font="Arial">';
			str += '<a href="' + link + '" target="_blank"><b>' + xml.nick + '</b></a>';
			str += ' @' + username;
			str += '</font>';
			
			
			if (Win.tqq_selfname != username) {
				str += '  <font color="#666666">';
				str += '<a href="event:follow,' + username + '"><font color="#666666">收听</font></a> | ';
				str += '<a href="event:talk,' + username + '"><font color="#666666">对话</font></a>';
				str += '</font>';
			}
			
			str += '<br />';
			
			img = xml.image.text();
			
			var val:String = xml.text.text();
			
			if (val) {
				str += Tools.tqq_format(val);
			}
			
			if (xml.type == "2") {

				if (xml.source.image) {
					img = xml.source.image;
				}
				
				if (val) {
					str += '<br />';
				}
				
				str += '<font color="#aaaaaa">【转】</font>';

				str += '<a href="http://t.qq.com/' + xml.source.name + '" target="_blank"><b>' + xml.source.nick + '</b></a>：';
				
				str += Tools.tqq_format(xml.source.text);
				
			}
			
			str = Tools.rn(str);
			
			txt.wordWrap = true;
			txt.styleSheet = sheetText;
			txt.htmlText = str;
			
			txt.background = true;
			txt.backgroundColor = 0x222222;
			
			if (img) {
				// /120 /160 /460 /2000
				var i:Image = new Image(img + "/120", 120, 120, img + "/2000", false);
				image.addChild(i);
			}
			
			str = '<a href="http://t.qq.com/p/t/' + xml.id + '" target="_blank">' + Tools.timeago(xml.timestamp) + '</a>  ';
			str += '来自' + xml.from;
			str += '   <a href="event:readd,' + xml.id + '">转播</a>';
			str += '(<a href="http://t.qq.com/p/t/'+xml.id+'" target="_blank"><b>' + Tools.num_format(xml.count) + '</b></a>)';
			
			str += '   <a href="event:reply,' + xml.id + '">回复</a>';
			
			if (xml.self == "1") {
				
				str += '   <a href="event:del,'+xml.id+'">删除</a>';
				
			}
			
			info.wordWrap = true;
			info.styleSheet = sheetInfo;
			info.htmlText = str;
			
			///20 /30 /40 /50 /100 
			var head:String = xml.head.text();
			var size:Number = 50;
			if (head) {
				head = head + "/" + size;
			} else {
				head = "http://mat1.gtimg.com/www/mb/images/head_50.jpg";
			}
			var a:Image = new Image(head, size, size, link);
			avatar.addChild(a);
			
			if (xml.type == "2" && xml.source) {
				if (xml.source.head && xml.source.name != username) {
					head = xml.source.head.text();
					var b:Image = new Image(head + "/20", 20, 20);
					b.mouseChildren = false;
					b.mouseEnabled = false;
					b.x = 30;
					b.y = 30;
					avatar.addChild(b);
				}
			}
			
		}

		public function resizeHandler(_tw:Number, _th:Number):void {

			tw = _tw;
			th = _th;
			
			layout();

		}
		
		public function layout():void {
			
			if (!mc || !mc.numChildren) {
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
			
			if (i > 0) {
				
				var tweet:DisplayObject = mc.getChildAt(i - 1);
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