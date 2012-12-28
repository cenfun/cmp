package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;

	public class Encrypt extends MovieClip {
		//解密钥匙，必须与加密钥匙一致
		private var key:String = "bbs.cenfun.com";
		private var encrypt_lists:String;
		private var lists:Array = [];
		//cmp的api接口
		private var api:Object;
		public function Encrypt():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			encrypt_lists = api.config.encrypt_lists;
			if (encrypt_lists) {
				lists = array(encrypt_lists);
			}
			next();
		}

		private function load():void {
			var url:String = lists.shift();
			url = api.cmp.constructor.fU(url);
			//api.tools.output(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(new URLRequest(url));
		}

		private function errorHandler(e:Event):void {
			next();
		}

		private function completeHandler(e:Event):void {
			var str:String = e.target.data;
			if (! str) {
				next();
				return;
			}
			try {
				str = decrypt(str);
			} catch (e) {
				next();
				return;
			}
			api.sendEvent("list_loaded", str);
			next();
		}

		private function next():void {
			if (lists.length) {
				load();
			}
		}

		private function decrypt(str:String):String {
			var keyBytes:ByteArray = new ByteArray();
			keyBytes.writeUTFBytes(key);
			keyBytes.position = 0;
			//
			var bytes:ByteArray = Base64.decode(str);
			bytes.position = 0;
			//
			var newBytes:ByteArray = XXTEA.decrypt(bytes, keyBytes);
			newBytes.position = 0;
			//
			var strOut:String = newBytes.readUTFBytes(newBytes.length);
			return strOut;
		}
		
		public const COMMA:RegExp = /\s*\,\s*/;
		public function array(input:String):Array {
			input = String(input);
			var arr:Array = input.split(COMMA);
			var out:Array = [];
			for each(var str:String in arr) {
				if (str) {
					out.push(str);
				}
			}
			return out;
		}


	}

}