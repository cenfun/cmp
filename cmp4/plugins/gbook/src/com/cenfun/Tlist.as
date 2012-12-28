package com.cenfun{

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.media.Video;
	
	public class Tlist extends MovieClip {
		public static const NEXT_PAGE:String = "next_page";
		
		public var tw:Number;
		public var th:Number;
		public var xml:XML;
		
		private var timeid:uint
		public function Tlist():void {
			scrollbar.visible = false;
			scrollbar.addEventListener(Event.CHANGE, scrollChange);
			
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
		}
		private function mouseWheel(e:MouseEvent):void {
			var num:Number = e.delta;
			var h:Number = 10 * num;
			setPane(pane.y + h);
			setScroll();
			checkNextPage();
		}
		
		private function setScroll():void {
			var per:Number =  - (pane.y / (pane.height - th));
			scrollbar.percent = per;
		}
		
		
		private function scrollChange(e:Event = null):void {
			updatePanePos();
			checkNextPage();
		}
		
		private function checkNextPage():void {
			clearTimeout(timeid);
			if (scrollbar.percent == 1) {
				timeid = setTimeout(sendNextPage, 500);
			}
		}
		
		private function sendNextPage():void {
			dispatchEvent(new Event(NEXT_PAGE));
		}
		
		private function updatePanePos():void {
			var per:Number = scrollbar.percent;
			var py:Number = - Math.round((pane.height - th) * per);
			setPane(py);
		}
		
		private function setPane(py:Number):void {
			if (py >= 0) {
				py = 0;
			} else if (py < th - pane.height) {
				py = th - pane.height;
			}
			pane.y = py;
		}
		
		public function show(_xml:XML, remove:Boolean = true):void {
			xml = _xml;
			
			var pos:Number = 0;
			//清除列表，回到顶部
			if (remove) {
				scrollbar.percent = 0;
				Tools.clear(pane);
			} else {
				//记录位置
				pos = pane.y;
			}
			
			var info_list:XMLList = xml.data.info;
			if (info_list && info_list.children().length()) {
				for each (var info:XML in info_list) {
					
					var tweet:Tweet = new Tweet();
					tweet.show(info, pane);
					pane.addChild(tweet);
					
				}
				
			} 
			
			if (pane.numChildren == 0) {
				var tf:TextField = new TextField();
				tf.defaultTextFormat = new TextFormat(null, 12, 0xffffff);
				tf.autoSize = "left";
				tf.htmlText = "没有找到任何相关内容";
				pane.addChild(tf);
			}
			
			layout(pos);
			
		}

		public function resizeHandler(_tw:Number, _th:Number):void {

			tw = _tw;
			th = _th;
			
			layout();

		}
		
		public function layout(pos:Number = 0):void {
			
			var l:Number = pane.numChildren;
			for (var i:int = 0; i < l; i ++) {
				var tweet:DisplayObject = pane.getChildAt(i);
				if (tweet) {
					if (tweet is Tweet) {
						var t:Tweet = tweet as Tweet;
						t.resizeHandler(tw - ScrollBar.WIDTH, th);
					} else {
						if (tweet.width > tw) {
							tweet.width = tw;
						}
					}
				}
			}
			
			//===================================
			//更新到添加后的位置
			if (pos) {
				setPane(pos);
				setScroll();
			}
			
			updatePanePos();
			
			scrollbar.resizeHandler(tw, th, pane.height);
			
			
			this.graphics.clear();
			this.graphics.beginFill(0x000000, 0);
			this.graphics.drawRect(0, 0, tw, th);
			this.graphics.endFill();
			
			
			scrollRect = new Rectangle(0, 0, tw, th);
			
		}


	}

}