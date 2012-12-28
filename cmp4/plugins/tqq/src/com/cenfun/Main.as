package com.cenfun{

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;
	import flash.geom.*;
	import com.adobe.crypto.*;
	
	public class Main extends MovieClip {
		public var tw:Number;
		public var th:Number;
		
		public function Main():void {
			tweet_num.mouseEnabled = title_lt.mouseEnabled = title_rt.mouseEnabled = false;
		}

		public function resizeHandler(_tw:Number, _th:Number):void {
			tw = _tw;
			th = _th;
			scrollRect = new Rectangle(0, 0, tw, th);
			layout();
		}
		
		public function layout():void {
			var c:Number = Math.round(tw * 0.5);
			var w:Number = c - 10;
			
			var rx:Number = w + 20;
			
			separator.x = c;
			separator.height = th;
			
			//==================================
			
			avatar.x = rx + 2;
			
			title_rt.x = rx;
			
			userlink.autoSize = userinfo.autoSize = username.autoSize = "left";
			userlink.x = userinfo.x = username.x = rx + 58;
			
			bt_follow.x = rx;
			is_follow.x = rx + 8;
			bt_talk.x = rx + 60;
			
			
			//=============================================================
			bg_tweet.width = w;
			
			tweet_text.width = w - 2;
			
			tweet_num.x = w - tweet_num.width;
			tweet_menu.x = w - tweet_menu.width;
			
			//=============================================================
			
			tweet_list_rt.x = rx;
			
			
			tweet_list_lt.resizeHandler(w, th - tweet_list_lt.y);
			tweet_list_rt.resizeHandler(w, th - tweet_list_rt.y);
			
		}


	}

}