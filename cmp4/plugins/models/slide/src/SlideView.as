package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.net.*;
	import flash.text.*;
	import flash.utils.*;
	import flash.ui.*;
	import flash.geom.*;
	
	public class SlideView extends Sprite {
		private var api:Object;
		private var _width:Number = 0;
		private var _height:Number = 0;
		
		private var main:Sprite;
		private var text:TextField;
		
		private var tx:Number;
		private var ty:Number;
		
		public function SlideView(_api:Object, xl:XMLList):void {
			api = _api;
			
			_width = api.config.video_width;
			_height = api.config.video_height;
			
			main = new Sprite();
			addChild(main);
			text = new TextField();
			text.autoSize = "left";
			text.selectable = false;
			text.multiline = true;
			text.wordWrap = true;

			//text.border = true;
			//text.borderColor = 0xffffff;
			tx = 5;
			ty = 5;
			var xywh:String = xl.@xywh;
			if (xywh) {
				var p:Array = api.tools.strings.xywh(xywh, _width, _height);
				tx = p[0];
				ty = p[1];
			}
			text.x = tx;
			text.y = ty;
			var format:TextFormat = api.tools.strings.format(xl);
			if (format) {
				text.defaultTextFormat = format;
			}
			
			var a:Number = api.tools.strings.per(api.tools.strings.gOP(xl, "alpha", 1));
			text.alpha = a;
			
			var f:Array = api.tools.graphics.filters(xl);
			text.filters = f;
			
			addChild(text);
			//
			resize();
			
		}
		
		public function addSlide(img:SlideLoader, bgcolor:uint, duration:Number):MovieClip {
			
			
			var str:String = (img.index + 1) + "/" + duration;
			var label:String = img.xml.@label;
			if (label) {
				str += " " + label;
			}
			text.htmlText = str;
			
			//自适应宽高
			api.tools.zoom.fit(img, _width, _height, 1);
			//
			var mc:MovieClip = new MovieClip();
			api.tools.graphics.back(mc, 0, 0, _width, _height, 1, bgcolor);
			mc.addChild(img);
			main.addChild(mc);
			//超过2个就移除最前面一个，回收内存
			if (main.numChildren > 2) {
				main.removeChildAt(0);
			}
			
			return mc;
		}
		
		public function resize():void {
			
			//填充背景
			api.tools.graphics.back(this, 0, 0, _width, _height, 0, 0x000000);
			//限定区域
			scrollRect = new Rectangle(0, 0, _width, _height);
			
			var tw:Number = _width - tx * 2;
			if (tw <= 0) {
				tw = _width - tx;
				if (tw <= 0) {
					tw = 0;
				}
			}
			text.width = tw;
			
			if (numChildren) {
				
				for (var i:int = 0; i < main.numChildren; i ++) {
					var child:DisplayObject = main.getChildAt(i);
					api.tools.zoom.fit(child, _width, _height, 1);
				}
				
			}
			
		}
		
		override public function set width(v:Number):void {
			if (v != _width) {
				_width = v;
				resize();
			}
		}
		
		override public function get width():Number {
			return _width;
		}
		
		
		override public function set height(v:Number):void {
			if (v != _height) {
				_height = v;
				resize();
			}
		}
		override public function get height():Number {
			return _height;
		}
		
		
	}
	
}