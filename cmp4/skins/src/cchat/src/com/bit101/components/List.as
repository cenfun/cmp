package com.bit101.components{
	import flash.display.*;
	import flash.events.*;

	public class List extends Component {
		public var panel:Panel;
		
		protected var _items:Array;
		protected var _itemHolder:Sprite;
		protected var _listItemHeight:Number = 20;
		protected var _listItemClass:Class = ListItem;
		protected var _scrollbar:VScrollBar;
		protected var _selectedIndex:int = -1;
		protected var _defaultColor:uint = Style.LIST_DEFAULT;
		protected var _alternateColor:uint = Style.LIST_ALTERNATE;
		protected var _selectedColor:uint = Style.LIST_SELECTED;
		protected var _rolloverColor:uint = Style.LIST_ROLLOVER;
		protected var _alternateRows:Boolean = false;


		private var _sortOn:String;
		
		public var labelField:String = "label";

		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this List.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param items An array of items to display in the list. Either strings or objects with label property.
		 */
		public function List(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, items:Array=null) {
			if (items != null) {
				_items = items;
			} else {
				_items = new Array();
			}
			super(parent, xpos, ypos);
		}


		public function sortOn(v:String):void {
			if (v) {
				_sortOn = v;
			} else {
				_sortOn = null;
			}
		}

		/**
		 * Initilizes the component.
		 */
		protected override function init():void {
			super.init();
			setSize(100, 100);
			addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			addEventListener(Event.RESIZE, onResize);
			makeListItems();
			fillItems();
		}

		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren():void {
			super.addChildren();
			panel = new Panel(this,0,0);
			panel.color = _defaultColor;
			_itemHolder = new Sprite();
			panel.content.addChild(_itemHolder);
			_scrollbar = new VScrollBar(this,0,0,onScroll);
			_scrollbar.setSliderParams(0, 0, 0);
		}

		/**
		 * Creates all the list items based on data.
		 */
		protected function makeListItems():void {
			var item:ListItem;
			while (_itemHolder.numChildren > 0) {
				item = ListItem(_itemHolder.getChildAt(0));
				item.removeEventListener(MouseEvent.CLICK, itemClick);
				item.removeEventListener(MouseEvent.ROLL_OVER, itemOver);
				item.removeEventListener(MouseEvent.ROLL_OUT, itemOut);
				_itemHolder.removeChildAt(0);
			}

			var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems,_items.length);
			numItems = Math.max(numItems,0);
			for (var i:int = 0; i < numItems; i++) {

				item = new _listItemClass(_itemHolder,0,i * _listItemHeight);
				item.setSize(width, _listItemHeight);
				item.defaultColor = _defaultColor;
				item.labelField = labelField;
				item.selectedColor = _selectedColor;
				item.rolloverColor = _rolloverColor;
				item.addEventListener(MouseEvent.CLICK, itemClick);
				item.addEventListener(MouseEvent.ROLL_OVER, itemOver);
				item.addEventListener(MouseEvent.ROLL_OUT, itemOut);
			}
		}

		protected function fillItems():void {
			
			if (!_itemHolder.numChildren) {
				return;
			}

			if (_sortOn) {
				_items.sortOn(_sortOn);
			}

			var offset:int = _scrollbar.value;
			var numItems:int = Math.ceil(_height / _listItemHeight);
			numItems = Math.min(numItems, _items.length);
			
			for (var i:int = 0; i < numItems; i++) {
				var item:ListItem = _itemHolder.getChildAt(i) as ListItem;
				if (offset + i < _items.length) {
					item.data = _items[offset + i];
				} else {
					item.data = "";
				}
				if (_alternateRows) {
					item.defaultColor = ((offset + i) % 2 == 0) ? _defaultColor : _alternateColor;
				} else {
					item.defaultColor = _defaultColor;
				}
				if (offset + i == _selectedIndex) {
					item.selected = true;
				} else {
					item.selected = false;
				}
			}

			dispatchEvent(new CE(CE.CHANGE, numItems));

		}

		/**
		 * If the selected item is not in view, scrolls the list to make the selected item appear in the view.
		 */
		protected function scrollToSelection():void {
			var numItems:int = Math.ceil(_height / _listItemHeight);
			if (_selectedIndex != -1) {
				if (_scrollbar.value > _selectedIndex) {
					//                    _scrollbar.value = _selectedIndex;
				} else if (_scrollbar.value + numItems < _selectedIndex) {
					_scrollbar.value = _selectedIndex - numItems + 1;
				}
			} else {
				_scrollbar.value = 0;
			}
			fillItems();
		}



		///////////////////////////////////
		// public methods
		///////////////////////////////////

		/**
		 * Draws the visual ui of the component.
		 */
		public override function draw():void {
			super.draw();

			_selectedIndex = Math.min(_selectedIndex,_items.length - 1);


			// panel
			panel.setSize(_width, _height);
			panel.color = _defaultColor;
			panel.draw();

			// scrollbar
			_scrollbar.x = _width - 10;
			var contentHeight:Number = _items.length * _listItemHeight;
			_scrollbar.setThumbPercent(_height / contentHeight);
			var pageSize:Number = Math.floor(_height / _listItemHeight);
			_scrollbar.maximum = Math.max(0,_items.length - pageSize);
			_scrollbar.pageSize = pageSize;
			_scrollbar.height = _height;
			_scrollbar.draw();
			scrollToSelection();
		}

		/**
		 * Adds an item to the list.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 */
		public function addItem(item:Object):void {
			_items.push(item);
			invalidate();
			makeListItems();
			fillItems();
		}

		/**
		 * Adds an item to the list at the specified index.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 * @param index The index at which to add the item.
		 */
		public function addItemAt(item:Object, index:int):void {
			index = Math.max(0,index);
			index = Math.min(_items.length,index);
			_items.splice(index, 0, item);
			invalidate();
			fillItems();
		}


		public function replaceItem(newItem:Object, oldItem:Object):void {

			var index:int = _items.indexOf(oldItem);

			if (index < 0 || index >= _items.length) {
				return;
			}

			_items[index] = newItem;
			invalidate();
			fillItems();

		}

		/**
		 * Removes the referenced item from the list.
		 * @param item The item to remove. If a string, must match the item containing that string. If an object, must be a reference to the exact same object.
		 */
		public function removeItem(item:Object):void {
			var index:int = _items.indexOf(item);
			removeItemAt(index);
		}

		/**
		 * Removes the item from the list at the specified index
		 * @param index The index of the item to remove.
		 */
		public function removeItemAt(index:int):void {
			if (index < 0 || index >= _items.length) {
				return;
			}
			_items.splice(index, 1);

			makeListItems();
			invalidate();
			fillItems();
		}

		/**
		 * Removes all items from the list.
		 */
		public function removeAll():void {
			_items.length = 0;
			invalidate();
			fillItems();
		}





		///////////////////////////////////
		// event handlers
		///////////////////////////////////

		/**
		 * Called when a user selects an item in the list.
		 */
		protected function itemClick(e:MouseEvent):void {
			if (! (e.currentTarget is ListItem)) {
				return;
			}
			var item:ListItem = e.currentTarget as ListItem;

			var offset:int = _scrollbar.value;

			for (var i:int = 0; i < _itemHolder.numChildren; i++) {
				var child:DisplayObject = _itemHolder.getChildAt(i);
				if (child is ListItem) {
					var theItem:ListItem = child as ListItem;
					if (theItem == item) {
						_selectedIndex = i + offset;
					}
					theItem.selected = false;
				}
			}
			item.selected = true;
			dispatchEvent(new Event(Event.SELECT));
			dispatchEvent(new CE(CE.LIST_ITEM_CLICK, item));
		}

		protected function itemOver(e:MouseEvent):void {
			if (! (e.currentTarget is ListItem)) {
				return;
			}
			var item:ListItem = e.currentTarget as ListItem;
			dispatchEvent(new CE(CE.LIST_ITEM_OVER, item));
		}
		protected function itemOut(e:MouseEvent):void {
			if (! (e.currentTarget is ListItem)) {
				return;
			}
			var item:ListItem = e.currentTarget as ListItem;
			dispatchEvent(new CE(CE.LIST_ITEM_OUT, item));
		}

		/**
		 * Called when the user scrolls the scroll bar.
		 */
		protected function onScroll(event:Event):void {
			fillItems();
		}

		/**
		 * Called when the mouse wheel is scrolled over the component.
		 */
		protected function onMouseWheel(event:MouseEvent):void {
			_scrollbar.value -=  event.delta;
			fillItems();
		}

		protected function onResize(event:Event):void {
			makeListItems();
			fillItems();
		}
		///////////////////////////////////
		// getter/setters
		///////////////////////////////////

		/**
		 * Sets / gets the index of the selected list item.
		 */
		public function set selectedIndex(value:int):void {
			if (value >= 0 && value < _items.length) {
				_selectedIndex = value;
				//_scrollbar.value = _selectedIndex;
			} else {
				_selectedIndex = -1;
			}
			invalidate();
			dispatchEvent(new Event(Event.SELECT));
		}
		public function get selectedIndex():int {
			return _selectedIndex;
		}

		/**
		 * Sets / gets the item in the list, if it exists.
		 */
		public function set selectedItem(item:Object):void {
			var index:int = _items.indexOf(item);
			//if(index != -1)
			//{
			selectedIndex = index;
			invalidate();
			dispatchEvent(new Event(Event.SELECT));
			//}
		}
		public function get selectedItem():Object {
			if (_selectedIndex >= 0 && _selectedIndex < _items.length) {
				return _items[_selectedIndex];
			}
			return null;
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

		/**
		 * Sets the height of each list item.
		 */
		public function set listItemHeight(value:Number):void {
			_listItemHeight = value;
			makeListItems();
			invalidate();
		}
		public function get listItemHeight():Number {
			return _listItemHeight;
		}

		/**
		 * Sets / gets the list of items to be shown.
		 */
		public function set items(value:Array):void {
			_items = value;
			invalidate();
		}
		public function get items():Array {
			return _items;
		}


		public function get length():int {
			if (_items) {
				return _items.length;
			}
			return 0;
		}

		/**
		 * Sets / gets the class used to render list items. Must extend ListItem.
		 */
		public function set listItemClass(value:Class):void {
			_listItemClass = value;
			makeListItems();
			invalidate();
		}
		public function get listItemClass():Class {
			return _listItemClass;
		}

		/**
		 * Sets / gets the color for alternate rows if alternateRows is set to true.
		 */
		public function set alternateColor(value:uint):void {
			_alternateColor = value;
			invalidate();
		}
		public function get alternateColor():uint {
			return _alternateColor;
		}

		/**
		 * Sets / gets whether or not every other row will be colored with the alternate color.
		 */
		public function set alternateRows(value:Boolean):void {
			_alternateRows = value;
			invalidate();
		}
		public function get alternateRows():Boolean {
			return _alternateRows;
		}

		/**
		         * Sets / gets whether the scrollbar will auto hide when there is nothing to scroll.
		         */
		public function set autoHideScrollBar(value:Boolean):void {
			_scrollbar.autoHide = value;
		}
		public function get autoHideScrollBar():Boolean {
			return _scrollbar.autoHide;
		}

	}
}