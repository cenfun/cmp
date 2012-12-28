package {

	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.external.*;
	import flash.text.*;

	public class CMPLoader extends MovieClip {
		private var api:Object;
		private var tw:Number;
		private var th:Number;
		private var flash_js:Boolean;
		private var loader:Loader = new Loader();
		private var mytext:TextField;
		private var cmp_path:String;
		private var cmp_host:String;
		private var loader_url:String = "cmp_new.swf";
		public function CMPLoader() {
			Security.allowDomain("*");
			//取得用户路径========================================;
			var loader_url:String = root.loaderInfo.loaderURL;
			//可能存在参数形式的地址，如cmp.swf?uid=1，先过滤
			var cmp_url:String = loader_url.split("?")[0];
			//取得路径，过滤参数后，并截取到最后一个斜杠的位置
			cmp_path = cmp_url.substring(0,cmp_url.lastIndexOf("/") + 1);
			//是否在网络
			if (Security.sandboxType == Security.REMOTE) {
				var path:String = cmp_path;
				var parr:Array = path.split("//");
				var host:String = parr[1] || parr[0];
				host = host.substring(0,host.indexOf("/"));
				cmp_host = path.substring(0,path.indexOf(host) + host.length);
			}
			//左对齐，不缩放
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, resize);
			resize();
			//
			loadCMP();
		}
		private function resize(e:Event = null):void {
			tw = stage.stageWidth;
			th = stage.stageHeight;
			layoutLoading();
			layoutMytext();
		}
		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//CMP的api相关，同插件里面一样
			flash_js = api.config.flash_js;
			//api.tools.output(flash_js);
			//需要使用api可以在这里自行添加
		}
		private function loadCMP():void {
			loader_url = formatURL(loader_url);
			var req:URLRequest = new URLRequest(loader_url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.contentLoaderInfo.sharedEvents.addEventListener('api', apiHandler);
			loader.load(req);
		}
		private function formatURL(url:String):String {
			//必须在网络环境才进行转换，本地路径，在不同操作系统有所不同，不进行转换
			if (url && cmp_host) {
				var src:String = url.split("?")[0];
				if (src.indexOf(":") != -1) {
					return url;
				} else if (src.substr(0, 1) == "/") {
					return cmp_host + url;
				} else {
					return cmp_path + url;
				}
			}
			return url;
		}
		private function completeHandler(e:Event):void {
			//trace(e);
			stage.removeEventListener(Event.RESIZE, resize);
			removeChild(loading);
			addChild(loader);
		}
		private function ioErrorHandler(e:IOErrorEvent):void {
			removeChild(loading);
			//trace(e);
			var htm:String = 'CMP加载错误：<a href="' + loader_url + '" target="_blank">' + loader_url + '</a>';
			mytext = new TextField();
			var f:TextFormat = new TextFormat(null,null,0xff0000);
			mytext.defaultTextFormat = f;
			mytext.multiline = true;
			mytext.autoSize = "left";
			mytext.htmlText = htm;
			mytext.setTextFormat(f);
			addChild(mytext);
			if (mytext.width > tw) {
				mytext.wordWrap = true;
				mytext.width = tw;
			}
			layoutMytext();
		}
	
		private function layoutLoading():void {
			if (loading) {
				loading.x = tw * 0.5;
				loading.y = th * 0.5;
			}
		}
	
		private function layoutMytext():void {
			if (mytext) {
				mytext.x = (tw - mytext.width) * 0.5;
				mytext.y = (th - mytext.height) * 0.5;
			}
		}
		private function progressHandler(e:ProgressEvent):void {
			var p:String = "";
			if (e.bytesTotal) {
				p = Math.round(e.bytesLoaded / e.bytesTotal * 99) + "";
			}
			loading.per.text = p;
			layoutLoading();
		}
	}
}