package com.cenfun{
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.display.*;

	public class Image extends MovieClip {
		private var loader:Loader;
		private var url:String;
		private var tw:Number;
		private var th:Number;
		private var link:String;
		private var scale:Boolean;
		private var border:Sprite;
		public function Image(_url:String, _tw:Number, _th:Number, _link:String = "", _scale:Boolean = true):void {
			url = _url;
			tw = _tw;
			th = _th;
			link = _link;
			scale = _scale;
			
			graphics.beginFill(0xaaaaaa);
			graphics.drawRect(-2, -2, tw + 4, th + 4);
			graphics.endFill();
			graphics.beginFill(0x161616);
			graphics.drawRect(-1, -1, tw + 2, th + 2);
			graphics.endFill();
			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, tw, th);
			graphics.endFill();
			
			border = new Sprite();
			border.graphics.beginFill(0xffffff);
			border.graphics.drawRect(-2, -2, tw + 4, th + 4);
			border.graphics.drawRect(-1, -1, tw + 2, th + 2);
			border.graphics.endFill();
			border.visible = false;
			addChild(border);

			if (! url) {
				return;
			}
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageError);
			var request:URLRequest = new URLRequest(url);
			try {
				loader.load(request);
			} catch (e:Error) {
			}
			addChild(loader);
		}
		private function imageComplete(e:Event):void {
			if (scale) {
				loader.width = tw;
				loader.height = th;
			} else {
				var w:Number = loader.width;
				var h:Number = loader.height;
				var twh:Number = w / h;
				var pwh:Number = tw / th;
				if (twh > pwh) {
					w = tw;
					h = w / twh;
				} else {
					h = th;
					w = h * twh;
				}
				loader.x = Math.round((tw - w) * 0.5);
				loader.y = Math.round((th - h) * 0.5);
				loader.width = Math.round(w);
				loader.height = Math.round(h);
			}
			if (! link) {
				return;
			}
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, imageClick);
			addEventListener(MouseEvent.ROLL_OVER, imageOver);
			addEventListener(MouseEvent.ROLL_OUT, imageOut);
		}

		private function imageError(e:IOErrorEvent):void {
		}
		private function imageClick(e:Event):void {
			try {
				navigateToURL(new URLRequest(link), "_blank");
			} catch (e:Error) {
			}
		}
		private function imageOver(e:Event):void {
			border.visible = true;
		}
		private function imageOut(e:Event):void {
			border.visible = false;
		}

	}
}