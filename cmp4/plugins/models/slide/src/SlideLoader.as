package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.text.TextField;

	public class SlideLoader extends Sprite {
		public var index:Number = 0;
		public var xml:XML;
		public var url:String;
		public var loader:Loader;
		public var info:LoaderInfo;

		public var loaded:Boolean = false;
		public var loading:Boolean = false;

		public var nowComplete:Function;
		public var nowProgress:Function;
		
		public var onComplete:Function;
		public var onProgress:Function;

		public function SlideLoader(_index:Number, _xml:XML):void {
			index = _index;
			xml = _xml;
			url = xml.@src;
		}

		public function load(_onComplete:Function, _onProgress:Function, now:Boolean = true):void {
			if (now) {
				nowComplete = _onComplete;
				nowProgress = _onProgress;
			} else {
				onComplete = _onComplete;
				onProgress = _onProgress;
			}
			
			if (loaded) {
				callback();
				return;
			}
			if (loading) {
				return;
			}
			
			loading = true;
			loader = new Loader();
			info = loader.contentLoaderInfo;
			info.addEventListener(Event.COMPLETE, completeHandler);
			info.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			info.addEventListener(ProgressEvent.PROGRESS, progressHandler);

			var request:URLRequest = new URLRequest(url);
			try {
				loader.load(request);
			} catch(e:Error) {
				
			}
		}
		
		public function clear():void {
			nowComplete = null;
			nowProgress = null;
			onComplete = null;
			onProgress = null;
		}
		
		private function completeHandler(e:Event):void {
			var type:String = info.contentType;
			if (type && type != "application/x-shockwave-flash") {
				if (info.childAllowsParent) {
					//平滑处理，需要安全权限
					var bm:Bitmap = info.content as Bitmap;
					try {
						bm.smoothing = true;
					} catch (e:Error){
					}
				}
			}
			addChild(loader);
			callback();
		}

		private function errorHandler(e:IOErrorEvent):void {
			var sp:Sprite = new Sprite();
			sp.graphics.beginFill(0x000000, 0);
			sp.graphics.drawRect(0, 0, 150, 50);
			sp.graphics.endFill();
			addChild(sp);
			
			var tt:TextField = new TextField();
			tt.htmlText = '<font color="#ff0000">error</font>';
			tt.selectable = false;
			tt.autoSize = "left";
			sp.addChild(tt);
			
			tt.x = (sp.width - tt.width) * 0.5;
			tt.y = (sp.height - tt.height) * 0.5;
			
			callback();
		}

		private function callback():void {
			loaded = true;
			loading = false;
			if (nowComplete is Function) {
				nowComplete(this);
			}
			if (onComplete is Function) {
				onComplete(this);
			}
		}

		private function progressHandler(e:ProgressEvent):void {
			loaded = false;
			loading = true;
			var per:Number = 0;
			if (e.bytesTotal) {
				per = e.bytesLoaded / e.bytesTotal;
			}
			if (nowProgress is Function) {
				nowProgress(this, per);
			}
			if (onProgress is Function) {
				onProgress(this, per);
			}
		}

	}

}