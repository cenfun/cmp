

package src{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.net.*;
	import flash.geom.*;

	public class Tag extends Sprite {

		private var _obj:Object;
		private var _color_up:Number;
		private var _color_on:Number;

		
		private var _bmp:BitmapText;
		private var _back:Sprite;
		private var _item:Sprite;

		public var cx:Number;
		public var cy:Number;
		public var cz:Number;
		public var active:Boolean = false;

		public function Tag(obj:Object, color_up:uint, color_on:uint, size:uint) {
			_obj = obj;
			_color_up = color_up;
			_color_on = color_on;
			// create the text field
			var format:TextFormat = new TextFormat();
			format.font = "Arial";
			format.bold = true;
			format.color = color_up;
			format.size = size;
			//
			_bmp = new BitmapText(_obj.label,format);
			addChild(_bmp);

			// scale and add
			_bmp.x =  -  _bmp.width * 0.5;
			_bmp.y =  -  _bmp.height * 0.5;
			// create the back
			var bx:Number = -( _bmp.width * 0.5 ) - 10;
			var by:Number = -( _bmp.height * 0.5 ) - 2;
			var bw:Number = _bmp.width + 20;
			var bh:Number = _bmp.height + 5;
			
			_back = new Sprite();
			_back.graphics.beginFill(0, 0);
			_back.graphics.lineStyle(1, color_on);
			_back.graphics.drawRect(bx, by, bw, bh);
			_back.graphics.endFill();
			addChildAt(_back, 0);
			_back.visible = false;
			
			
			_item = new Sprite();
			_item.graphics.beginFill(0, 0);
			_item.graphics.lineStyle(1, color_up);
			_item.graphics.drawRect(bx, by, bw, bh);
			_item.graphics.endFill();
			addChildAt(_item, 0);
			_item.visible = false;

			// force mouse cursor on rollover
			mouseChildren = false;
			buttonMode = true;
			useHandCursor = true;
			//events
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
		}

		private function mouseOverHandler( e:MouseEvent ):void {
			_back.visible = true;
			setColor(_color_on);
			active = true;
		}

		private function mouseOutHandler( e:MouseEvent ):void {
			_back.visible = false;
			setColor(_color_up);
			active = false;
		}

		private function setColor(c:uint):void {
			var ct:ColorTransform = new ColorTransform();
			ct.color = c;
			_bmp.transform.colorTransform = ct;
		}

		private function clickHandler( e:MouseEvent ):void {
			_obj.play();
		}
		
		public function checkItem(o:Object):void {
			if (o.xml == _obj.xml) {
				_item.visible = true;
			} else {
				_item.visible = false;
			}
		}

	}

}