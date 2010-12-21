package {

	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.text.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.geom.*;
	import flash.system.*;


	public class Ads extends MovieClip {
		private var api:Object;

		private var tw:Number;
		private var th:Number;
		
		private var firstPlaying:Boolean;
		private var autoResume:Boolean;
		
		private var nowAd:Object;
		
		private var ads:Array = [];
		
		private var timeid:uint;
		private var duration:int;

		public function Ads():void {
			
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			
			bt.visible = false;
			bt.addEventListener(MouseEvent.CLICK, clickHandler);
			tt.visible = false;
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
			
			if (api.config.ads) {
				ads = api.tools.strings.json(api.config.ads);
				if (ads.length) {
					api.addEventListener(apikey.key, "resize", resizeHandler);
					api.addEventListener(apikey.key, "model_state", stateHandler);
					api.addEventListener(apikey.key, "model_start", startHandler);
					resizeHandler();
				}
			}
		}
		
		private function startHandler(e:Event):void {
			firstPlaying = true;
			autoResume = false;
		}
		
		private function clearAd():void {
			clearInterval(timeid);
			bt.visible = false;
			tt.visible = false;
			//清除之前广告
			ad.graphics.clear();
			while (ad.numChildren) {
				ad.removeChildAt(0);
			}
			nowAd = null;
		}
		
		private function showAd(state:String):void {
			clearAd();
			//取得新状态下的广告
			var arr:Array = [];
			for each (var obj:Object in ads) {
				if (obj.onstate == state) {
					arr.push(obj);
				}
			}
			if (arr.length) {
				nowAd = arr[Math.floor(arr.length * Math.random())];
				if (nowAd.loader) {
					ad.addChild(nowAd.loader);
					layout();
				} else {
					loadAd();
				}
			}
		}
		
		private function loadAd():void {
			if (nowAd.src) {
				var src:String = api.cmp.constructor.fU(nowAd.src);
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				//api.tools.output(src);
				var req:URLRequest = new URLRequest(src);
            	loader.load(req);
				nowAd.loader = loader;
				ad.addChild(loader);
			}
		}
		
		private function completeHandler(e:Event):void {
			var loader:Loader = e.target.loader;
			loader.x = - loader.width * 0.5;
			loader.y = - loader.height * 0.5;
			layout();
        }

		private function ioErrorHandler(e:IOErrorEvent):void {
            //trace("ioErrorHandler: " + e);
        }
		
		
		private function resizeHandler(e:Event = null):void {
			tw = api.config.width;
			th = api.config.height;
			layout();
		}
		
		private function layout():void {
			if (nowAd && nowAd.loader && ad.numChildren) {
				var ax:Number = 0;
				var ay:Number = 0;
				var aw:Number = tw;
				var ah:Number = th;
				if (nowAd.target == "video") {
					ax = api.win_list.media.x + api.win_list.media.video.x;
					ay = api.win_list.media.y + api.win_list.media.video.y;
					aw = api.config.video_width;
					ah = api.config.video_height;
				} else if (nowAd.target == "lrc") {
					ax = api.win_list.lrc.x + api.win_list.lrc.text.x;
					ay = api.win_list.lrc.y + api.win_list.lrc.text.y;
					aw = api.config.lrc_width;
					ah = api.config.lrc_height;
				} 
				
				ad.x = ax + aw * 0.5;
				ad.y = ay + ah * 0.5;
				
				with (ad.graphics) {
					clear();
					beginFill(0x000000, 0.1);
					drawRect(- aw * 0.5, - ah * 0.5, aw, ah);
					endFill();
				}
				
				duration = parseInt(nowAd.duration);
				
				if (!isNaN(duration) && duration > 0) {
					tt.visible = true;
					tt.time.text = "剩余" + duration;
					tt.time.autoSize = "left";
					tt.time.selectable = false;
					with (tt.graphics) {
						clear();
						beginFill(0xffffff, 1);
						drawRect(0, 0, tt.time.width + 4, tt.time.height);
						endFill();
					}
					tt.x = ax + aw - tt.width;
					tt.y = ay;
					clearInterval(timeid);
					timeid = setInterval(timeHandler, 1000);
					
				} else {
					bt.visible = true;
					bt.x = ax + aw - bt.width;
					bt.y = ay;
				}
			}
		}
		
		private function timeHandler():void {
			duration --;
			if (duration > 0) {
				tt.time.text = "剩余" + duration;
			} else {
				clearInterval(timeid);
				finish();
			}
		}
		
		private function clickHandler(e:MouseEvent):void {
			finish();
		}
		
		private function finish():void {
			clearAd();
			if (autoResume) {
				autoResume = false;
				resumeVideo();
			}
		}

		private function stateHandler(e:Event = null):void {
			var s:String = api.config.state;
			switch (s) {
				case "playing" :
					if (firstPlaying) {
						firstPlaying = false;
						//自动恢复暂停
						pauseVideo();
						autoResume = true;
						//
						showAd(s);
					} else {
						clearAd();
					}
					break;
				case "undefined" :
				case "connecting" :
				case "buffering" :
				case "paused" :
				case "stopped" :
				case "completed" :
					showAd(s);
					break;
				default :
			}
		}
		
		private function resumeVideo():void {
			if (api.config.state == "paused") {
				api.sendEvent("view_play");
			}
		}
		private function pauseVideo():void {
			if (api.config.state == "playing") {
				api.sendEvent("view_play");
			}
		}


	}
}