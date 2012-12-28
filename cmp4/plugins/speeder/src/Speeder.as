package  {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	
	public class Speeder extends MovieClip {
		private var api:Object;
		private var tw:Number;
		private var th:Number;

		public var now:Number;
		
		public var up_speeds:Array = [];
		public var dn_speeds:Array = [];
		
		public function Speeder():void {
			
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			
			bt_close.addEventListener(MouseEvent.CLICK, closeClick);
			
			info.visible = false;
			tips.visible = false;
			bt_test.visible = false;
			bt_test.addEventListener(MouseEvent.CLICK, testClick);
			
			
			
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
			
			readme.autoSize = "left";
			readme.width = 270;
			
			if (api.config.speeder_readme) {
				
				readme.htmlText = api.config.speeder_readme;
				
			}
			
			bg.height = readme.y + readme.height + 5;
			
			
			api.addEventListener(apikey.key, "resize", resizeHandler);
			resizeHandler();

			start();
			
		}
		
		private function resizeHandler(e:Event = null):void {
			tw = api.config.width;
			th = api.config.height;
			
			this.x = (tw - bg.width) * 0.5;
			this.y = (th - bg.height) * 0.5;
			
		}
		
		
		public function closeClick(e:MouseEvent):void {
			visible = false;
			
		}
		
		public function testClick(e:MouseEvent):void {
			
			start();
			
		}
		
		
		public function start():void {
			tips.visible = false;
			bt_test.visible = false;
			loading.visible = true;
			
			if (!up_speeds.length) {
				info.visible = false;
			} else {
				info.alpha = 0.2;
			}
			
			
			up_test();
		}
		
		public function done():void {
			tips.visible = true;
			bt_test.visible = true;
			loading.visible = false;
			
			if (!visible) {
				return;
			}
			
			var up_sn:Number = up_speeds[up_speeds.length - 1];
			var up_sa:Number = getSpeed(up_speeds);
			
			var dn_sn:Number = dn_speeds[dn_speeds.length - 1];
			var dn_sa:Number = getSpeed(dn_speeds);
			
			
			var max_bar:Number = 270;
			
			var ms:Number = Math.max(up_sn, Math.max(up_sa, Math.max(dn_sn, dn_sa)));
			
			var max_spd:Number = Math.ceil(ms * 0.1) * 10;
			
			
			info.up_now.width = Math.round(max_bar * up_sn / max_spd);
			info.up_avg.width = Math.round(max_bar * up_sa / max_spd);
			info.up_txt.htmlText = '上传速度：'+up_sn+'kb/s (平均：<font color="#0051CC"><b>'+up_sa+'kb/s</b></font>)';
			
			info.dn_now.width = Math.round(max_bar * dn_sn / max_spd);
			info.dn_avg.width = Math.round(max_bar * dn_sa / max_spd);
			info.dn_txt.htmlText = '下载速度：'+dn_sn+'kb/s (平均：<font color="#007A00"><b>'+dn_sa+'kb/s</b></font>)';
			
			info.visible = true;
			info.alpha = 1;
		}
		
		
		public function getSpeed(list:Array):Number {
			var len:int = list.length;
			var num:Number = 0;
			for (var i:int = 0; i < len; i ++) {
				num += list[i];
			}
			
			var val:Number = Math.round(num / len);
			
			return val;
		}
		
		public function getNow():Number {
			var d:Date = new Date();
			var t:Number = d.getTime();
			return t;
		}
		public function up_test():void {
			var t:Number = getNow();
			now = t;
			var up_url:String = "http://tool.115.com/live/speed_api/";
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, up_done);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, up_done);
			var request:URLRequest = new URLRequest(up_url);
			//up=102400个0
			var zero102400:String = "";
			for (var i:int = 0; i < 102400; i ++) {
				zero102400 += "0";
			}
			var variables:URLVariables = new URLVariables();
            variables.up = zero102400;
            request.data = variables;
            request.method = URLRequestMethod.POST;
            loader.load(request);
		}
		private function up_done(e:Event):void {
            //trace("up done: " + e);
			var t:Number = getNow();
			var speed:Number = Math.round(102400 / (t - now));
			up_speeds.push(speed);
			dn_test(); 
        }
		public function dn_test():void {
			var t:Number = getNow();
			now = t;
			var dn_url:String = "http://tool.115.com/api/tools_speedtest.php?time=" + t;
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, dn_done);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dn_done);
			var request:URLRequest = new URLRequest(dn_url);
            loader.load(request);
		}
		private function dn_done(e:Event):void {
            //trace("dn done: " + e);
			var t:Number = getNow();
			var speed:Number = Math.round(102400 / (t - now));
			dn_speeds.push(speed);
			done(); 
        }

	}
	
}
