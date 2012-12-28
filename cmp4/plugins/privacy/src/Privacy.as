package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.ui.*;

	public class Privacy extends MovieClip {
		private var privacy_url:String;
		private var privacy_readme:String = "请输入列表密码";
		private var privacy_content:String;
		//cmp的api接口
		private var api:Object;
		public function Privacy():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			win.visible = false;
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
			//
			if (api.config.privacy_readme) {
				privacy_readme = api.config.privacy_readme;
			}
			privacy_url = api.config.privacy_url;
			if (privacy_url) {
				load();
			}
			api.addEventListener(apikey.key, "resize", resizeHandler);
		}
		
		private function resizeHandler(e = null):void {
			win.x = api.config.width * 0.5;
			win.y = api.config.height * 0.5;
		}

		private function load():void {
			var url:String = api.cmp.constructor.fU(privacy_url);
			//api.tools.output(url);
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, completeHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.load(new URLRequest(url));
		}

		private function errorHandler(e:Event):void {
		}

		private function completeHandler(e:Event):void {
			var str:String = e.target.data;
			if (! str) {
				return;
			}
			privacy_content = str;
			//
			win.readme.htmlText = privacy_readme;
			win.bt_ok.addEventListener(MouseEvent.CLICK, okClick);
			//
			win.password.displayAsPassword = true;
			win.password.addEventListener(KeyboardEvent.KEY_DOWN, okKeydown);
			setFocus(win.password);
			//
			win.visible = true;
			resizeHandler();
		}
		
		private function setFocus(io:InteractiveObject):void {
			if (stage && io) {
				stage.focus = io;
			}
		}
		private function okKeydown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER) {
				okClick();
			}
		}
	
		private function okClick(e:MouseEvent = null):void {
			
			var str_key:String = win.password.text;
			
			if (!str_key) {
				setFocus(win.password);
				return;
			}
			
			var md5:String = MD5.hash("CMP" + str_key);
			md5 = MD5.hash(md5.toUpperCase()).toUpperCase();
			
			var str:String;
			
			try {
				str = decrypt(privacy_content, md5);
			} catch (e) {
				
				win.readme.htmlText = '<font color="#ff0000">解密失败</font>\n' + privacy_readme;
				win.password.text = "";
				setFocus(win.password);
				return;
			}
			win.readme.htmlText = "解密成功";
			win.visible = false;
			api.sendEvent("list_loaded", str);
		}
		
		
		private function decrypt(str:String, key:String):String {
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