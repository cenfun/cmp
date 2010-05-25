package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;

	public class Encrypt extends MovieClip {
		//解密密匙，如果需要改动，请一定保持与php程序里的加密密匙一样
		private var key:String = "756e35bd9441e66e001ca73024b9b426";
		private var encrypt_source:String;
		private var encrypt_position:String;
		//cmp的api接口
		private var api:Object;
		public function Encrypt():void {
			this.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			encrypt_source = api.config.encrypt_source;
			encrypt_position = api.config.encrypt_position;
			load();
		}

		private function load():void {
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(new URLRequest(encrypt_source));
		}

		private function errorHandler(e:Event):void {
			output(e);
		}

		private function completeHandler(e:Event):void {
			var data:String = e.target.data;
			if (! data) {
				return;
			}
			try {
				data = decrypt(data);
				var xml:XMLList = new XMLList(data);
			} catch (e) {
				output(e);
				return;
			}
			var cmp_list:XML = api.list_xml as XML;
			var pos:uint = parseInt(encrypt_position) || 1;
			var child:XML = cmp_list.children()[pos - 1];
			if (child) {
				cmp_list.insertChildBefore(child, xml);
			} else {
				cmp_list.appendChild(xml);
			}
			api.sendEvent("list_loaded");
		}

		private function output(input:*):void {
			if (api) {
				api.tools.output(input);
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


	}

}