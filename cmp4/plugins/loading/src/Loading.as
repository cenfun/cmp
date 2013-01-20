package {

	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.system.*;
	import flash.utils.*;
	import flash.text.*;

	public class Loading extends MovieClip {

		public var api:Object;
		private var tw:Number;
		private var th:Number;
		
		public var loading_per:String = "";
		public var loading_url:String = "";
		
		public var loader:Loader = new Loader();
		
		
		
		public var main:Sprite = new Sprite();
		public var text:TextField = new TextField();
		
		public function Loading() {
			
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api',apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
			
			main.visible = false;
			addChild(main);
			
			text.visible = false;
			text.mouseEnabled = false;
			text.multiline = true;
			text.wordWrap = false;
			text.autoSize = "left";
			addChild(text);
			
			
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
			
			
			var version:Number = parseInt(api.config.version.substr(-6));
			
			//api.tools.output(version);
			
			if (!api.hasOwnProperty("addModel") || version < 120729) {
				var tf:TextField = new TextField();
				tf.autoSize = "left";
				tf.defaultTextFormat = new TextFormat(null, 12, 0xff0000, true);
				tf.htmlText = '<a href="http://cmp.cenfun.com/download/cmp4">当前版本CMP4不支持loading插件，请点击下载并升级到最新版</a>';
				addChild(tf);
				return;
			}
			
			
			//load ===================================================================
			loading_per = api.config.loading_per;
			loading_url = api.config.loading_url;
			
			if (!loading_per && !loading_url) {
				return;
			}
			
			if (loading_url) {
				//加载文件信息
				var req:URLRequest = new URLRequest(loading_url);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete, false, 0, true);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onError, false, 0, true);
				try {
				
					loader.load(new URLRequest(loading_url));
				
				} catch (e:Error) {
					onError();
				}
			}
			
			//events ================================================================
			api.addEventListener(apikey.key, "resize", resizeHandler);
			api.addEventListener(apikey.key, "model_state", stateHandler);
			api.addEventListener(apikey.key, "model_start", startHandler);
			
		}
		
		public function onError(e:Event = null):void {
		}
		//信息加载完成
		public function onComplete(e:Event):void {
			main.addChild(loader);
		}
		
		private function startHandler(e:Event):void {
			hide();
		}
		
		private function resizeHandler(e:Event = null):void {
			layout();
		}
		
		public function layout():void {
			tw = api.config.width;
			th = api.config.height;
			if (main.visible) {
				main.x = (tw - main.width) * 0.5;
				main.y = (th - main.height) * 0.5;
			}
			
			if(text.visible) {
				text.x = (tw - text.width) * 0.5;
				text.y = (th - text.height) * 0.5;
			}
		}
		
		
		private function stateHandler(e:Event = null):void {
			var s:String = api.config.state;
			if (s == "connecting" || s == "buffering") {
				show();
			} else {
				hide();
			}
		}
		
		
		private function hide():void {
			main.visible = false;
			text.visible = false;
		}
		private function show():void {
			if (main.numChildren) {
				api.win_list.media.video.vi.visible = false;
				main.visible = true;
			}
			
			
			if (loading_per) {
				var str:String = api.tools.strings.auto(loading_per, api.item);
				str = api.tools.strings.auto(loading_per, api.config);
				
				//api.tools.output(str);
				
				text.htmlText = str;
				text.visible = true;
				
			}
			
			
			
			layout();
		}
		
	}

}