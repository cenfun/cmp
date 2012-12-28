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
		
		public var sheetText:StyleSheet = new StyleSheet();
		public var sheetInfo:StyleSheet = new StyleSheet();
		public function Tweet():void {
			sheetText.parseCSS("a { color:#367DD7; } a:hover { text-decoration:underline; }");
			sheetText.parseCSS("p { margin-left:20; } ");
			
			sheetInfo.parseCSS("a { color:#cccccc; } a:hover { text-decoration:underline; }");
			
			info.addEventListener(TextEvent.LINK,linkClick);
		}
		
		public function linkClick(e:TextEvent):void {
			if (!e.text) {
				return;
			}
			var arr:Array = e.text.split(",");
			if (arr[0] == "del") {
				var p:DisplayObject = parent.parent.parent.parent;
				if (p is Win) {
					var w:Win = p as Win;
					w.tweetDel(arr[1]);
				}
				
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
			
			var link:String = "http://t.qq.com/" + xml.name;
			
			var str:String = '<a href="' + link + '" target="_blank"><b>' + xml.nick + '</b></a>';
			
			str += '<font color="#aaaaaa">';
			if (xml.type == "2") {
				str += ' 转播';
			}
			str += "：</font>"
			
			str += Tools.tqq_format(xml.text);
			
			var img:String;
			
			if (xml.image) {
				img = xml.image;
			}
			
			if (xml.type == "2") {

				if (xml.source.image) {
					img = xml.source.image;
				}
				
				str += '<br><li>';
			
				str += '<a href="http://t.qq.com/' + xml.source.name + '" target="_blank"><b>' + xml.source.nick + '</b></a>：';
				
				str += Tools.tqq_format(xml.source.text);
				
				str += '</li>';
				
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
			
			var count:String = Tools.num_format(xml.count);
			
			str = "" + Tools.timeago(xml.timestamp) + '  来自' + xml.from;
			str += '  <a href="http://t.qq.com/p/t/'+xml.id+'" target="_blank">转播(<b>' + count + '</b>)</a>';
			
			if (xml.self == "1") {
				
				str += '   <a href="event:del,'+xml.id+'">删除</a>';
				
			}
			
			
			info.styleSheet = sheetInfo;
			info.htmlText = str;
			
			///20 /30 /40 /50 /100 
			var a:Image = new Image(xml.head + "/30", 30, 30, link);
			avatar.addChild(a);
			
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
			
			image.x = txt.x + 2;
			image.y = h + 5;
			
			info.width = txt.width;
			info.autoSize = "left";
			info.y = image.y + image.height;
			
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