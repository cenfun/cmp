package  {
	import flash.events.Event;
	public final class CE extends Event {
		

		
		public static const CHANGE:String = "change";
		
		public static const LIST_ITEM_OVER:String = "list_item_over";
		public static const LIST_ITEM_OUT:String = "list_item_out";
		public static const LIST_ITEM_CLICK:String = "list_item_click";
		
		//传递事件数据========================================================
		private var _data:Object;
		//创建CMPEvent
		public function CE(type:String, d:Object = null, bubble:Boolean = false, cancelable:Boolean = false):void {
			super(type, bubble, cancelable);
			_data = d;
		}
		//返回事件数据
		public function get data():Object {
			return _data;
		}
		
		//修改事件数据
		public function set data(d:Object):void {
			_data = d;
		}
		
		override public function toString():String {
			return "[CE]";
		}
		
		override public function clone():Event {
			return new CE(type, bubbles, cancelable);
		}
		
	}
}