package {
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	
	public final class Debug extends Object {
		
		private static var lc:LocalConnection = new LocalConnection();
		//输出函数(output)
		public static function show(... rest):void {
			var str:String = rest.join(", ");
			lc.addEventListener(StatusEvent.STATUS, function(e:Event):void{});
			var s:String = "(" + System.totalMemory + " B) " + str.toString();
			trace(s);
			lc.send("_cenfun_lc", "cenfunTrace", s);
		}
		
	}
}