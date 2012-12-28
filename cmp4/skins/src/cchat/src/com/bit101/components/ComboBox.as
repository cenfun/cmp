package com.bit101.components{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ComboBox extends Component {
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";

		protected var _defaultLabel:String = "";
		protected var _dropDownButton:PushButton;
		protected var _items:Array;
		protected var _labelButton:PushButton;
		protected var _list:List;
		protected var _numVisibleItems:int = 6;
		protected var _open:Boolean = false;
		protected var _openPosition:String = TOP;
		protected var _stage:Stage;
		
		public var value:String = "";
		
		/**
		 * Constructor
		 * @param parent The parent DisplayObjectContainer on which to add this List.
		 * @param xpos The x position to place this component.
		 * @param ypos The y position to place this component.
		 * @param defaultLabel The label to show when no item is selected.
		 * @param items An array of items to display in the list. Either strings or objects with label property.
		 */
		public function ComboBox(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0, defaultLabel:String="", items:Array = null) {
			_defaultLabel = defaultLabel;
			_items = items;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			super(parent, xpos, ypos);
		}

		/**
		 * Initilizes the component.
		 */
		protected override function init():void {
			super.init();
			setSize(100, 20);
			setLabelButtonLabel();
		}

		/**
		 * Creates and adds the child display objects of this component.
		 */
		protected override function addChildren():void {
			super.addChildren();
			_list = new List(null,0,0,_items);
			_list.autoHideScrollBar = true;
			_list.addEventListener(Event.SELECT, onSelect);
			_labelButton = new PushButton(this,0,0,"",onDropDown);
			_labelButton.algin = PushButton.LEFT;
			_dropDownButton = new PushButton(this,0,0,"+",onDropDown);
		}

		/**
		 * Determines what to use for the main button label and sets it.
		 */
		protected function setLabelButtonLabel():void {
			var val:String;
			if (!selectedItem) {
				val = _defaultLabel;
			} else if (selectedItem is String) {
				val = selectedItem as String;
			} else if (selectedItem.hasOwnProperty(labelField)) {
				val = selectedItem[labelField];
			} else {
				val = selectedItem.toString();
			}
			_labelButton.label = val;
			value = val;
			
			dispatchEvent(new CE(CE.CHANGE, val));
			
		}

		/**
		 * Removes the list from the stage.
		 */
		protected function removeList():void {
			if (_stage.contains(_list)) {
				_stage.removeChild(_list);
			}
			_stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			_dropDownButton.label = "+";
		}



		///////////////////////////////////
		// public methods
		///////////////////////////////////

		public override function draw():void {
			super.draw();
			_labelButton.setSize(_width - _height + 1, _height);
			_labelButton.draw();

			_dropDownButton.setSize(_height, _height);
			_dropDownButton.draw();
			_dropDownButton.x = _width - height;

			_list.setSize(_width, _numVisibleItems * _list.listItemHeight);
		}


		/**
		 * Adds an item to the list.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 */
		public function addItem(item:Object):void {
			_list.addItem(item);
		}

		/**
		 * Adds an item to the list at the specified index.
		 * @param item The item to add. Can be a string or an object containing a string property named label.
		 * @param index The index at which to add the item.
		 */
		public function addItemAt(item:Object, index:int):void {
			_list.addItemAt(item, index);
		}

		/**
		 * Removes the referenced item from the list.
		 * @param item The item to remove. If a string, must match the item containing that string. If an object, must be a reference to the exact same object.
		 */
		public function removeItem(item:Object):void {
			_list.removeItem(item);
		}

		/**
		 * Removes the item from the list at the specified index
		 * @param index The index of the item to remove.
		 */
		public function removeItemAt(index:int):void {
			_list.removeItemAt(index);
		}

		/**
		 * Removes all items from the list.
		 */
		public function removeAll():void {
			_list.removeAll();
		}




		///////////////////////////////////
		// event handlers
		///////////////////////////////////

		/**
		 * Called when one of the top buttons is pressed. Either opens or closes the list.
		 */
		protected function onDropDown(event:MouseEvent):void {
			_open = ! _open;
			if (_open) {
				var point:Point = new Point();
				if (_openPosition == BOTTOM) {
					point.y = _height;
				} else {
					point.y =  -  _numVisibleItems * _list.listItemHeight;
				}
				point = this.localToGlobal(point);
				_list.move(point.x, point.y);
				_stage.addChild(_list);
				_stage.addEventListener(MouseEvent.CLICK, onStageClick);
				_dropDownButton.label = "-";
			} else {
				removeList();
			}
		}

		/**
		 * Called when the mouse is clicked somewhere outside of the combo box when the list is open. Closes the list.
		 */
		protected function onStageClick(event:MouseEvent):void {
			// ignore clicks within buttons or list
			if (event.target == _dropDownButton || event.target == _labelButton) {
				return;
			}
			if (new Rectangle(_list.x,_list.y,_list.width,_list.height).contains(event.stageX,event.stageY)) {
				return;
			}

			_open = false;
			removeList();
		}

		/**
		 * Called when an item in the list is selected. Displays that item in the label button.
		 */
		protected function onSelect(event:Event):void {
			_open = false;
			_dropDownButton.label = "+";
			if (stage != null && stage.contains(_list)) {
				stage.removeChild(_list);
			}
			setLabelButtonLabel();
			dispatchEvent(event);
		}

		/**
		 * Called when the component is added to the stage.
		 */
		protected function onAddedToStage(event:Event):void {
			_stage = stage;
		}

		/**
		 * Called when the component is removed from the stage.
		 */
		protected function onRemovedFromStage(event:Event):void {
			removeList();
		}

		///////////////////////////////////
		// getter/setters
		///////////////////////////////////

		/**
		 * Sets / gets the index of the selected list item.
		 */
		public function set selectedIndex(value:int):void {
			_list.selectedIndex = value;
			setLabelButtonLabel();
		}
		public function get selectedIndex():int {
			return _list.selectedIndex;
		}

		/**
		 * Sets / gets the item in the list, if it exists.
		 */
		public function set selectedItem(item:Object):void {
			_list.selectedItem = item;
			setLabelButtonLabel();
		}
		public function get selectedItem():Object {
			return _list.selectedItem;
		}

		/**
		 * Sets/gets the default background color of list items.
		 */
		public function set defaultColor(value:uint):void {
			_list.defaultColor = value;
		}
		public function get defaultColor():uint {
			return _list.defaultColor;
		}

		/**
		 * Sets/gets the selected background color of list items.
		 */
		public function set selectedColor(value:uint):void {
			_list.selectedColor = value;
		}
		public function get selectedColor():uint {
			return _list.selectedColor;
		}

		/**
		 * Sets/gets the rollover background color of list items.
		 */
		public function set rolloverColor(value:uint):void {
			_list.rolloverColor = value;
		}
		public function get rolloverColor():uint {
			return _list.rolloverColor;
		}

		/**
		 * Sets the height of each list item.
		 */
		public function set listItemHeight(value:Number):void {
			_list.listItemHeight = value;
			invalidate();
		}
		public function get listItemHeight():Number {
			return _list.listItemHeight;
		}

		/**
		 * Sets / gets the position the list will open on: top or bottom.
		 */
		public function set openPosition(value:String):void {
			_openPosition = value;
		}
		public function get openPosition():String {
			return _openPosition;
		}

		/**
		 * Sets / gets the label that will be shown if no item is selected.
		 */
		public function set defaultLabel(val:String):void {
			_defaultLabel = val;
			value = val;
			setLabelButtonLabel();
		}
		public function get defaultLabel():String {
			return _defaultLabel;
		}
		
		
		public function set labelField(value:String):void {
			_list.labelField = value;
		}
		public function get labelField():String {
			return _list.labelField;
		}
		
		public function sortOn(v:String):void {
			_list.sortOn(v);
		}

		/**
		 * Sets / gets the number of visible items in the drop down list. i.e. the height of the list.
		 */
		public function set numVisibleItems(value:int):void {
			_numVisibleItems = value;
			invalidate();
		}
		public function get numVisibleItems():int {
			return _numVisibleItems;
		}

		/**
		 * Sets / gets the list of items to be shown.
		 */
		public function set items(value:Array):void {
			_list.items = value;
		}
		public function get items():Array {
			return _list.items;
		}

		/**
		 * Sets / gets the class used to render list items. Must extend ListItem.
		 */
		public function set listItemClass(value:Class):void {
			_list.listItemClass = value;
		}
		public function get listItemClass():Class {
			return _list.listItemClass;
		}


		/**
		 * Sets / gets the color for alternate rows if alternateRows is set to true.
		 */
		public function set alternateColor(value:uint):void {
			_list.alternateColor = value;
		}
		public function get alternateColor():uint {
			return _list.alternateColor;
		}

		/**
		 * Sets / gets whether or not every other row will be colored with the alternate color.
		 */
		public function set alternateRows(value:Boolean):void {
			_list.alternateRows = value;
		}
		public function get alternateRows():Boolean {
			return _list.alternateRows;
		}

		/**
		 * Gets whether or not the combo box is currently open.
		 */
		public function get isOpen():Boolean {
			return _open;
		}
	}
}