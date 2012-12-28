package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.ui.*;

	public class Login extends MovieClip {
		private var login_handler:String;
		private var login_readme:String = "";
		//
		private var username:String = "";
		private var password:String = "";
		//cmp的api接口
		private var api:Object;
		public function Login():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			hideLoading();
			hide();
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
			if (api.config.login_readme) {
				login_readme = api.config.login_readme;
			}
			login_handler = api.config.login_handler;
			if (login_handler) {
				login_handler = api.cmp.constructor.fU(login_handler);
				// check login
				showLoading();
				var req:URLRequest = new URLRequest(login_handler);
				new MyLoader(req, loadError, loadProgress, checkComplete);
			}
			api.addEventListener(apikey.key, "resize", resizeHandler);
			
			win.bt_login.addEventListener(MouseEvent.CLICK, loginClick);
			win.password.displayAsPassword = true;
			win.password.addEventListener(KeyboardEvent.KEY_DOWN, inputKeydown);
			win.username.addEventListener(KeyboardEvent.KEY_DOWN, inputKeydown);
			
		}

		private function loadError(msg:String):void {
			hideLoading();
			showMsg(msg, true);
			show();
		}
		
		private function loadProgress(ebl:uint, ebt:uint):void {
			var str:String =  "";
			if (ebt) {
				str = Math.round(100 * ebl / ebt) + "%";
			}
		}
		
		
		private function checkComplete(ba:ByteArray):void {
			hideLoading();
			var str:String = ba + "";
			if (! str) {
				showMsg(login_readme);
				show();
				return;
			}
			
			showList(str);
			
		}
		
		//================================================================================
		
		private function inputKeydown(e:KeyboardEvent):void {
			if (e.keyCode == Keyboard.ENTER) {
				loginClick();
			}
		}
	
		private function loginClick(e:MouseEvent = null):void {
			
			username = win.username.text;
			if (!username) {
				setFocus(win.username);
				return;
			}
			password = win.password.text;
			if (!password) {
				setFocus(win.password);
				return;
			}
			var req:URLRequest = new URLRequest(login_handler);
			req.method = URLRequestMethod.POST;
			var vars:URLVariables = new URLVariables();
			vars.username = username;
			vars.password = password;
			req.data = vars;
			
			new MyLoader(req, loadError, loadProgress, loginComplete);
			showLoading();
		}

		private function loginComplete(ba:ByteArray):void {
			hideLoading();
			var str:String = ba + "";
			if (! str) {
				showMsg("登录失败，帐号或密码错误，请重试", true);
				show();
				return;
			}
			
			showList(str);
		}
		
		
		//================================================================================
		
		
		
		private function showList(str:String):void {
			api.sendEvent("list_loaded", str);
			hide();
		}
		
		private function showMsg(str:String = "", isErr:Boolean = false):void {
			
			var txt:String = str + "";
			if (isErr) {
				txt = '<font color="#ff0000">' + txt + '</font>'
			}
			
			win.readme.htmlText = txt;
		}
		
		private function show():void {
			win.visible = true;
			resizeHandler();
		}
		private function hide():void {
			win.visible = false;
		}
		
		private function showLoading():void {
			win.loading.visible = true;
		}
		private function hideLoading():void {
			win.loading.visible = false;
		}
		
		//=================================================================================
		private function resizeHandler(e = null):void {
			win.x = api.config.width * 0.5;
			win.y = api.config.height * 0.5;
		}
		
		private function setFocus(io:InteractiveObject):void {
			if (stage && io) {
				stage.focus = io;
			}
		}

	}

}