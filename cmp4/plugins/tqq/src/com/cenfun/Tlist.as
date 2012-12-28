package com.cenfun{

	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.text.*;
	import flash.geom.*;
	
	public class Tlist extends MovieClip {
		public var tw:Number;
		public var th:Number;
		public var xml:XML;
		
		public function Tlist():void {
			scrollbar.visible = false;
			scrollbar.addEventListener(Event.CHANGE, scrollChange);
			
			addEventListener(MouseEvent.MOUSE_WHEEL, mouseWheel);
		}
		private function mouseWheel(e:MouseEvent):void {
			var num:Number = e.delta;
			
			var h:Number = 10 * num;
			
			setPane(pane.y + h);
			
			var per:Number =  - (pane.y / (pane.height - th));
			
			scrollbar.percent = per;
			
		}
		
		private function scrollChange(e:Event = null):void {
			updatePanePos();
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
		
		public function show(_xml:XML):void {
			xml = _xml;
			
			Tools.clear(pane);
			scrollbar.percent = 0;
			
			var info_list:XMLList = xml.data.info;
			if (info_list && info_list.children().length()) {
				for each (var info:XML in info_list) {
					
					var tweet:Tweet = new Tweet();
					tweet.show(info, pane);
					pane.addChild(tweet);
				
				}
			}
			
			layout();
			
		}

		public function resizeHandler(_tw:Number, _th:Number):void {

			tw = _tw;
			th = _th;
			
			layout();

		}
		
		public function layout():void {
			
			var l:Number = pane.numChildren;
			for (var i:int = 0; i < l; i ++) {
				var tweet:DisplayObject = pane.getChildAt(i);
				if (tweet) {
					var t:Tweet = tweet as Tweet;
					t.resizeHandler(tw - ScrollBar.WIDTH, th);
				}
			}
			
			//===================================
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