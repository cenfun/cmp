package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.media.Video;

	public class Announce extends MovieClip {
		//cmp的api接口引用
		private var api:Object;
		
		private var pw:Number;
		private var ph:Number;
		
		private var announce_content:String = "生活需要音乐，欢迎使用<a href='http://bbs.cenfun.com/'><font color='#ff0000'><b>CMP</b></font></a> Life needs music, Welcome to CMP";
		private var announce_xywh:String = "0,0,100P,20";
		private var announce_speed:Number = 1;
		
		private var running:Boolean = false;

		public function Announce() {
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			
			bt_close.visible = false;
			bt_close.addEventListener(MouseEvent.CLICK, remove);
			addEventListener(MouseEvent.ROLL_OVER, over);
			addEventListener(MouseEvent.ROLL_OUT, out);
		}
		
		private function over(e:Event):void {
			bt_close.visible = true;
			pause();
		}
		private function out(e:Event):void {
			bt_close.visible = false;
			start();
		}

		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			
			if (api.config.announce_content) {
				announce_content = decodeURIComponent(api.config.announce_content);
			}
			if (api.config.announce_xywh) {
				announce_xywh = api.config.announce_xywh;
			}
			if (api.config.announce_speed) {
				announce_speed = parseInt(api.config.announce_speed);
			}
			
			init();
			
		}
		
		private function init():void {
			
			
			content.cacheAsBitmap = true;
			content.htmlText = String(announce_content);
			content.mask  = deck;
			content.autoSize = "left";
			
			resizeHandler();
			
			start();
		}
		
		private function start():void {
			addEventListener(Event.ENTER_FRAME, run);
			running = true;
		}
		private function pause():void {
			removeEventListener(Event.ENTER_FRAME, run);
		}
		
		
		private function remove(e:Event):void {
			
			pause();
			visible = false;
			
		}
		
		private function run(e:Event):void {
			var tx:Number = content.x - announce_speed;
			if (tx + content.width < bg.x) {
				content.x = bg.x + bg.width;
			} else {
				content.x = tx;
			}
		}
		
		private function resizeHandler(e:Event = null):void {
			//获取cmp的宽高
			pw = api.config.width;
			ph = api.config.height;
			
			//TweenNano.to(loader, 1, {alpha:1});
			
			var arr:Array = api.tools.strings.xywh(announce_xywh, pw, ph);
			
			//api.tools.output(arr);
			
			var tx:Number = arr[0];
			var ty:Number = arr[1];
			var tw:Number = arr[2];
			var th:Number = arr[3];
			
			deck.x = bg.x = tx;
			deck.y = bg.y = ty;
			deck.width = bg.width = tw;
			deck.height = bg.height = th;
			
			if (!running || content.x > tx + tw) {
				content.x = tx + tw;
			}
			content.y = ty + (th - content.height) * 0.5;
			
			bt_close.x = tx + tw - bt_close.width;
			bt_close.y = ty + (th - bt_close.height) * 0.5;
			
		}


	}

}