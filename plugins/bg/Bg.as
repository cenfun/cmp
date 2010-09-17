package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;

	public class Bg extends MovieClip {
		//cmp的api接口引用
		private var api:Object;
		
		private var bg_src:String = "bg";
		
		private var tw:Number;
		private var th:Number;

		public function Bg() {
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
		}


		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			api.addEventListener(apikey.key, "model_start", startHandler);
			api.addEventListener(apikey.key, 'resize', resizeHandler);
			resizeHandler();
			
			if (api.config.bg_src) {
				bg_src = api.config.bg_src;
			}
			
			if (api.config[bg_src]) {
				loadBg(api.config[bg_src]);
			}
			
		}
		
		private function resizeHandler(e:Event = null):void {
			//获取cmp的宽高
			tw = api.config.width;
			th = api.config.height;
			
			var i:int = 0;
			while (i < bgs.numChildren) {
				var child:DisplayObject = bgs.getChildAt(i);
				child.width = tw;
				child.height = th;
				i ++;
			}
			
		}
		
		private function startHandler(e:Event = null):void {
			var bg_url:String = api.item[bg_src];
			if (!bg_url) {
				return;
			}
			
			loadBg(bg_url);
		}
		
		private function loadBg(url:String):void {
			if (url) {
				url = api.cmp.constructor.fU(url);
			} else {
				return;
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			var request:URLRequest = new URLRequest(url);
            loader.load(request);
		}
		private function completeHandler(e:Event):void {
			
			//fadeOut之前的
			if (bgs.numChildren) {
				var child:DisplayObject = bgs.getChildAt(0);
				TweenNano.to(child, 1, {alpha:0, onComplete:function(){
					 bgs.removeChild(child);
				}});
			}
			
			
			//fadeIn新加载的
			var loader:Loader = e.target.loader as Loader;
			
			loader.alpha = 0;
			loader.width = tw;
			loader.height = th;
			bgs.addChild(loader);
			
			TweenNano.to(loader, 1, {alpha:1});
			
			
			
        }
		private function ioErrorHandler(e:IOErrorEvent):void {
        }



	}

}