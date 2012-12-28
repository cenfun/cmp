package com.bit101.components{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	
	public class ListItem extends Component {
		protected var _data:Object;
		protected var _icon:Sprite;
		protected var _label:Label;
		protected var _defaultColor:uint = 0xffffff;
		protected var _selectedColor:uint = 0xdddddd;
		protected var _rolloverColor:uint = 0xeeeeee;
		protected var _selected:Boolean;
		protected var _mouseOver:Boolean = false;
		
		public var labelField:String = "label";

		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this ListItem.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param data The string to display as a label or object with a label property.
		 */
		public function ListItem(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, data:Object = null) {
			_data = data;
			super(parent, xpos, ypos);
		}

		/**
		 * Initilizes the component.
		 */
		protected override function init():void {
			super.init();
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			setSize(100, 20);
		}

		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren():void {
			super.addChildren();
			_label = new Label(this,2,0);
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.draw();

			_icon = new Sprite();
			addChild(_icon);
		}

		///////////////////////////////////
		// public methods
		///////////////////////////////////

		/**
		 * Draws the visual ui of the component.
		 */
		public override function draw():void {
			super.draw();
			graphics.clear();

			if (_selected) {
				graphics.beginFill(_selectedColor);
			} else if (_mouseOver) {
				graphics.beginFill(_rolloverColor);
			} else {
				graphics.beginFill(_defaultColor);
			}
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();

			if (!_data) {
				return;
			}
			
			var str:String = "";
			
			if (_data.hasOwnProperty(labelField)) {
				str = _data[labelField];
			} else {
				str = String(_data);
			}
			
			_label.text = str;
			_label.scrollRect = new Rectangle(0,0,width - 5,height);
			_label.x = 2;
			_label.y = (height - _label.height) * 0.5;
			

		}




		///////////////////////////////////
		// event handlers
		///////////////////////////////////

		/**
		 * Called when the user rolls the mouse over the item. Changes the background color.
		 */
		protected function onMouseOver(event:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_mouseOver = true;
			invalidate();
		}

		/**
		 * Called when the user rolls the mouse off the item. Changes the background color.
		 */
		protected function onMouseOut(event:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			_mouseOver = false;
			invalidate();
		}



		///////////////////////////////////
		// getter/setters
		///////////////////////////////////

		/**
		 * Sets/gets the string that appears in this item.
		 */
		public function set data(value:Object):void {
			_data = value;
			invalidate();
		}
		public function get data():Object {
			return _data;
		}

		/**
		 * Sets/gets whether or not this item is selected.
		 */
		public function set selected(value:Boolean):void {
			_selected = value;
			invalidate();
		}
		public function get selected():Boolean {
			return _selected;
		}

		/**
		 * Sets/gets the default background color of list items.
		 */
		public function set defaultColor(value:uint):void {
			_defaultColor = value;
			invalidate();
		}
		public function get defaultColor():uint {
			return _defaultColor;
		}

		/**
		 * Sets/gets the selected background color of list items.
		 */
		public function set selectedColor(value:uint):void {
			_selectedColor = value;
			invalidate();
		}
		public function get selectedColor():uint {
			return _selectedColor;
		}

		/**
		 * Sets/gets the rollover background color of list items.
		 */
		public function set rolloverColor(value:uint):void {
			_rolloverColor = value;
			invalidate();
		}
		public function get rolloverColor():uint {
			return _rolloverColor;
		}

	}
}