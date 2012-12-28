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
			
		}

		public function resizeHandler(_tw:Number, _th:Number):void {
			tw = _tw;
			th = _th;
			scrollRect = new Rectangle(0, 0, tw, th);
			layout();
		}
		
		public function layout():void {
			
			bt_tweet.x = tw - bt_tweet.width;
			
			tweet_list.resizeHandler(tw, th - tweet_list.y);
			
		}


	}

}