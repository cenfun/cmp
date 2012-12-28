package {
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.display.Sprite;

	public final class MyLoader extends URLLoader {
		private var req:URLRequest;
		private var onerr:Function;
		private var oning:Function;
		private var onled:Function;
		public function MyLoader(_req:URLRequest, _onerr:Function, _oning:Function, _onled:Function):void {
			req = _req;
			onerr = _onerr;
			oning = _oning;
			onled = _onled;
			//
			dataFormat = URLLoaderDataFormat.BINARY;
			addEventListener(IOErrorEvent.IO_ERROR, onError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			addEventListener(ProgressEvent.PROGRESS, onProgress);
			addEventListener(Event.COMPLETE, onLoaded);
			
			try {
				load(req);
			} catch (e:Error) {
				onError();
			}
		}
		public function stop():void {
			try {
				close();
			} catch (e:Error) {
			}
		}
		private function onError(e:Event = null):void {
			//O.o("err");
			onerr.call(null, "Error load:" + req.url);
		}
		private function onProgress(e:ProgressEvent):void {
			//O.o("ing");
			oning.call(null, e.bytesLoaded, e.bytesTotal);
		}
		private function onLoaded(e:Event):void {
			//O.o("led");
			var ba:ByteArray = data;
			if (ba) {
				//检测是否是utf8，而且没有bom
				ba = bom(ba);
			}
			onled.call(null, ba);
		}
		
		
		public function bom(ba:ByteArray, len:int = 1000):ByteArray {
			if (ba.length < 3) {
				return ba;
			}
			//有BOM：EF BB BF
			ba.position = 0;
			var b1:int = ba.readUnsignedByte();
			var b2:int = ba.readUnsignedByte();
			var b3:int = ba.readUnsignedByte();
			//存在BOM直接返回
			if (b1 == 239 && b2 == 187 && b3 == 191){  
				return ba;
			}
			//可能不存在BOM的utf8格式检测
			ba.position = 0;
			var i:int = 0;
			//测试1000个字符是否符合utf-8
			while (ba.bytesAvailable && i < len) {
				var b:int = ba.readUnsignedByte();
				if (b <= 0x7F || (b >= 0xC2 && b <= 0xF4)) {
					if (b >= 0xC2) {
						var c:int = ba.readUnsignedByte();
						if (c < 0x80 || c > 0xBF) {
							return ba;
						}
						if (b >= 0xE0) {
							var d:int = ba.readUnsignedByte();
							if (d < 0x80 || d > 0xBF) {
								return ba;
							}
							if (b >= 0xF0) {
								var e:int = ba.readUnsignedByte();
								if (e < 0x80 || e > 0xBF) {
									return ba;
								}
							}
						}
					}
				} else {
					return ba;
				}
				i ++;
			}
			//是utf8但是没有BOM，则添加一个BOM并返回
			//trace("no bom");
			var a:ByteArray = new ByteArray();
			a.writeByte(239);
			a.writeByte(187);
			a.writeByte(191);
			a.writeBytes(ba);
			return a;
		}
		
	}
}