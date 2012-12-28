package com.bit101.components{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;

	public class Label extends Component {
		protected var _autoSize:Boolean = true;
		protected var _text:String = "";
		protected var _tf:TextField;

		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this Label.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param text The string to use as the initial text in this component.
		 */
		public function Label(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number =  0, text:String = "") {
			this.text = text;
			super(parent, xpos, ypos);

		}

		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren():void {
			_height = 18;
			_tf = new TextField();
			_tf.height = _height;
			_tf.defaultTextFormat = new TextFormat(Style.fontName,Style.fontSize,Style.LABEL_TEXT);
			_tf.htmlText = _text;
			addChild(_tf);
			draw();
		}




		///////////////////////////////////
		// public methods
		///////////////////////////////////

		/**
		 * Draws the visual ui of the component.
		 */
		override public function draw():void {
			super.draw();
			_tf.htmlText = _text;
			if (_autoSize) {
				_tf.autoSize = TextFieldAutoSize.LEFT;
				_width = _tf.width;
				dispatchEvent(new Event(Event.RESIZE));
			} else {
				_tf.autoSize = TextFieldAutoSize.NONE;
				_tf.width = _width;
			}
			_height = _tf.height = 18;
		}

		///////////////////////////////////
		// event handlers
		///////////////////////////////////

		///////////////////////////////////
		// getter/setters
		///////////////////////////////////

		/**
		 * Gets / sets the text of this Label.
		 */
		public function set text(t:String):void {
			_text = t;
			if (_text == null) {
				_text = "";
			}
			invalidate();
		}
		public function get text():String {
			return _text;
		}

		/**
		 * Gets / sets whether or not this Label will autosize.
		 */
		public function set autoSize(b:Boolean):void {
			_autoSize = b;
		}
		public function get autoSize():Boolean {
			return _autoSize;
		}

		/**
		 * Gets the internal TextField of the label if you need to do further customization of it.
		 */
		public function get textField():TextField {
			return _tf;
		}
		
		public function set styleSheet(v:StyleSheet):void {
			_tf.styleSheet = v;
		}
		
	}
}