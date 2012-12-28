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
	
	public class ScrollBar extends MovieClip {
		public static var WIDTH:Number = 15;
		private var tw:Number;
		private var th:Number;
		private var ph:Number;
		private var per:Number = 0;
		private var rect:Rectangle = new Rectangle();
		private var lock:Boolean = false;
		private var number:Number = 0;
		private var thumb_height:Number;
		public function ScrollBar():void {
			back.buttonMode = true;
			back.addEventListener(MouseEvent.MOUSE_DOWN, backDown);
			
			thumb.over.visible = false;
			thumb.buttonMode = true;
			thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumbDown);
			thumb.addEventListener(MouseEvent.ROLL_OVER, thumbOver);
			thumb.addEventListener(MouseEvent.ROLL_OUT, thumbOut);
		}
		
		//====================================================================================
		public function set percent(v:Number):void {
			if (v != per) {
				if (v < 0) {
					v = 0;
				} else if (v > 1) {
					v = 1;
				}
				per = v;
				updatePercent();
			}
		}
		
		public function get percent():Number {
			return per;
		}
		
		private function updatePercent():void {
			if (lock) {
				return;
			}
			thumb.y = Math.round(per * (th - thumb_height));
			
		}
		
		private function update(e:Event):void {
			if (th) {
				percent = thumb.y / (th - thumb_height);
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		//====================================================================================
		private function backDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, backUp);
			number = 0;
			addEventListener(Event.ENTER_FRAME, scrolling);
		}
		private function scrolling(e:Event):void {
			if (th) {
				var p:Number = mouseY / th;
				if (!number) {
					number = (per - p) * 0.1;
				}
				var v:Number = percent - number;
				if ((number > 0 && v < p) || (number < 0 && v > p)) {
					v = p;
					removeEventListener(Event.ENTER_FRAME, scrolling);
				}
				percent = v;
				number = number * 1.2;
				dispatchEvent(new Event(Event.CHANGE));
			}
			
		}
		private function backUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, backUp);
			removeEventListener(Event.ENTER_FRAME, scrolling);
			number = 0;
		}
		
		//====================================================================================
		private function thumbOver(e:MouseEvent):void {
			thumb.over.visible = true;
		}
		private function thumbOut(e:MouseEvent):void {
			thumb.over.visible = false;
		}
		private function thumbDown(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, thumbUp);
			lock = true;
			thumb.startDrag(false, rect);
			stage.addEventListener(MouseEvent.MOUSE_UP, thumbUp);
			stage.addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function thumbUp(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, thumbUp);
			stage.removeEventListener(Event.ENTER_FRAME, update);
			lock = false;
			thumb.stopDrag();
			
		}
		
		//====================================================================================

		public function resizeHandler(_tw:Number, _th:Number, _ph:Number):void {

			tw = _tw;
			th = _th;
			ph = _ph;
			
			
			if (th && th < ph) {
				visible = true;
			} else {
				per = 0;
				visible = false;
				return;
			}
			
			
			x = tw - WIDTH;
			
			thumb_height = Math.round(th * th / ph);
			if (thumb_height < 7) {
				thumb_height = 7;
			}
			thumb.back.height = thumb_height;
			thumb.icon.y = thumb.over.y = Math.floor(thumb_height * 0.5);
			
			back.height = th;
			rect = new Rectangle(0, 0, 0, th - thumb_height);
			
			updatePercent();
			
			
		}


	}

}