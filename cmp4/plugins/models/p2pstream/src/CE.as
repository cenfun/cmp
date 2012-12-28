package {
	import flash.events.Event;
	public final class CE extends Event {
		public static const HS_ERROR:String = "hs_error";
		public static const HS_PROGRESS:String = "hs_progress";
		public static const HS_COMPLETE:String = "hs_complete";
		
		
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