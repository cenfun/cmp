package {
	import flash.display.*;
	import flash.external.*;
	import flash.net.*;
	import flash.text.*;
	import flash.events.*;
	import flash.system.*;
	public class WeiboCallback extends MovieClip {
		
		public var conn:LocalConnection;
		
		public var vars:Object;
		
		public function WeiboCallback():void {
			Security.allowDomain("*");

			//stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			win_err.visible = false;
			win_suc.visible = false;

			vars = root.loaderInfo.parameters;

			if (vars.cn && vars.oauth_token && vars.oauth_verifier) {
				conn = new LocalConnection();
				conn.allowDomain("*");
				conn.client = this;
				conn.addEventListener(StatusEvent.STATUS, connStatus);
				conn.send(vars.cn, "callback", vars);
			} else {
				loading.visible = false;
				win_err.visible = true;
			}
		}

		public function connStatus(e:StatusEvent):void {
			loading.visible = false;
			if (e.level == "error") {
				win_err.msg.text = "连接CMP错误，无法返回数据";
				win_err.visible = true;
			} else if (e.level == "status") {
				win_suc.visible = true;
				if (vars.callback) {
					
					try {
						
						ExternalInterface.call(vars.callback, vars);
						
					} catch (e:Error) {
						
					}
					
				}
			}
		}


	}
}