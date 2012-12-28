package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	import fl.transitions.*;
	import fl.transitions.easing.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public final class SlideModel extends Object {
		public var url:String;
		public var position:Number = 0;
		public var duration:Number = 0;
		//下载字节和总字节
		public var bl:int;
		public var bt:int;
		//时间控制者
		public var timer:Sprite = new Sprite();
		public var timeid:uint;
		
		public var apikey:Object;
		public var api:Object;

		public var loader:URLLoader;
		
		//是否循环播放
		public var loop:Boolean = false;
		//每个图片停留时间，秒
		public var delay:Number = 3;
		//变换的时间，秒
		public var transition:Number = 0.5;
		//背景色
		public var bgcolor:uint = 0x000000;
		
		//图片列表
		public var list:Array = [];
		public var index:int = 0;
		//当前缓冲图
		public var nowimg:SlideLoader;
		//是否正在缓冲
		public var buffer:Boolean;
		//停止状态
		public var disabled:Boolean;
		//
		public var view:SlideView;
		public var options:Array;
		public function SlideModel(_apikey:Object):void {
			apikey = _apikey;
			api = apikey.api;
		}
		
		
		public function load():void {
			api.sendState("connecting");
			position = 0;
			duration = 0;
			index = 0;
			disabled = false;
			//
			url = api.item.url;
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(IOErrorEvent.IO_ERROR, xmlError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlError);
			loader.addEventListener(ProgressEvent.PROGRESS, xmlProgress);
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
			var req:URLRequest = new URLRequest(url);
			try {
				loader.load(req);
			} catch (e:Error) {
				xmlError(e);
			}
		}
		public function play():void {
			interval("add", [timeHandler]);
			api.sendState("playing");
			disabled = false;
			show();
		}
		public function pause():void {
			interval("del", [timeHandler]);
			api.sendState("paused");
		}
		public function stop():void {
			interval("del", [timeHandler]);
			disabled = true;
			view = null;
			//xml
			if (loader) {
				loader.removeEventListener(IOErrorEvent.IO_ERROR, xmlError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlError);
				loader.removeEventListener(ProgressEvent.PROGRESS, xmlProgress);
				loader.removeEventListener(Event.COMPLETE, xmlLoaded);
				try {
					loader.close();
				} catch (e:Error) {
				}
				loader = null;
			}
		}
		
		public function volume():void {
		}
		
		public function seek(val:Number):void {
			var pos:Number;
			if (val < 0) {
				pos = index - 1;
			} else if (val > 1) {
				pos = index + 1;
			} else {
				pos = Math.floor(duration * val);
			}
			pos = Math.round(pos);
			
			pos = api.tools.strings.clamp(pos, 0, duration - 1);
			
			if (pos != index) {
				
				index = pos;
				clearTimeout(timeid);
				show();
				
			}
			
		}
		
		//完成
		public function finish():void {
			//先停止当前模块
			stop();
			api.sendState("completed");
		}
		//=========================================================================================
		public function timeHandler(e:Event):void {
			if (position != api.item.position) {
				api.item.position = position * delay;
				api.sendEvent("model_time");
			}
			
		}
		
		public function show():void {
			if (disabled || api.config.state != "playing") {
				return;
			}
			var img:SlideLoader = list[index];
			
			if (img.loaded) {
				imgLoaded(img);
				
				if (img.index >= duration - 1) {
					api.sendEvent("model_loaded");
				}
				
				
			} else {
				buffer = false;
				imgStop();
				nowimg = img;
				img.load(imgLoaded, imgProgress, true);
			}
			
		}
		
		public function imgLoaded(img:SlideLoader):void {
			
			if (disabled) {
				return;
			}
			
			if (api.config.state == "buffering") {
				api.sendState("playing");
			}

			if (api.config.state != "playing") {
				return;
			}
			
			var mc:MovieClip = view.addSlide(img, bgcolor, duration);
			//随机选择一个效果进行变换
			var i:uint = Math.floor(Math.random() * options.length);
			TransitionManager.start(mc, options[i]);
			//延时加载下一个
			position = index + 1;
			clearTimeout(timeid);
			timeid = setTimeout(next, delay * 1000);
			
			//
			if (!buffer) {
				imgLoad();
			}
			
		}
		
		
		public function next():void {
			if (disabled) {
				return;
			}
			index ++;
			if (index >= duration) {
				if (loop) {
					index = 0;
				} else {
					finish();
					return;
				}
			}
			//下一个
			show();
		}
		
		//=========================================================================================
		public function xmlLoaded(e:Event):void {
			if (disabled) {
				return;
			}
			list = xmlParse(e.target.data);
			
			duration = list.length;
			
			if (duration) {
				
          		api.item.data = true;
				api.item.duration = duration * delay;
				api.sendEvent("model_start");
				
				play();
				
			} else {
				xmlError("xml格式解析错误");
			}
			
        }
		
		public function imgStop():void {
			if (disabled || !list) {
				return;
			}
			for (var i:int = 0; i < list.length; i ++) {
				var item:SlideLoader = list[i];
				item.clear();
			}
		}
		
		public function imgLoad(img:SlideLoader = null):void {
			if (disabled || !list) {
				return;
			}
			if (img) {
				if (img.index >= duration - 1) {
					api.sendEvent("model_loaded");
					return;
				}
			}
			buffer = true;
			for (var i:int = 0; i < list.length; i ++) {
				var item:SlideLoader = list[i];
				if (item && !item.loaded && !item.loading) {
					nowimg = item;
					item.load(imgLoad, imgProgress, false);
					break;
				}
			}
		}
		public function imgProgress(img:SlideLoader, per:Number):void {
			if (disabled) {
				return;
			}
			var pre:Number = 0;
			if (duration) {
				pre = (img.index + per) / duration;
			}
			//api.tools.output(per, img.index);
			if (nowimg == img) {
				api.sendEvent("model_loading", pre);
			}
			
			if (!buffer) {
				api.config.buffer_percent = Math.round(pre * 100);
				api.sendState("buffering");
			}
			
		}
		
		
		public function xmlParse(ba:ByteArray):Array {
			var arr:Array = [];
			if (ba) {
				var str:String = ba.toString();
				var xl:XMLList;
				try {
					xl = new XMLList(str);
				} catch (e:Error) {
				}
				if (xl) {
					//config====================================================
					loop = api.tools.strings.parse(xl.@loop) ? true : false;
					bgcolor = api.tools.strings.color(xl.@bgcolor);
					var d:Number = parseFloat(xl.@delay);
					if (isNaN(d) || d < 1) {
						delay = 3;
					} else {
						delay = d;
					}
					var t:Number = parseFloat(xl.@transition);
					if (isNaN(t) || t < 0.1) {
						transition = 0.5;
					} else {
						transition = t;
					}
					//初始化变换种类
					options = getOptions();
					
					//添加到视图
					view = new SlideView(api, xl);
					api.showMedia(view);
					
					//加载列表
					//==========================================================
					var i:Number = 0;
					for each (var xml:XML in xl.children()) {
						var src:String = xml.@src;
						if (src) {
							var img:SlideLoader = new SlideLoader(i, xml);
							arr.push(img);
							i ++;
						}
					}
					
				}
			}
			return arr;
		}
		

        public function xmlError(e:Object):void {
			api.sendEvent("model_error", e);
        }
		//下载状态
        public function xmlProgress(e:ProgressEvent):void {
			var pre:Number = 0;
			if (e.bytesTotal) {
				pre = e.bytesLoaded / e.bytesTotal;
			}
			//缓冲状态
			api.config.buffer_percent = Math.round(pre * 100);
			api.sendState("buffering");
        }
		
		
		//=========================================================================================
		public function interval(type:String, arr:Array):void {
			var f:Function;
			for (var i:int = 0; i < arr.length; i ++) {
				f = arr[i];
				if (f is Function) {
					timer.removeEventListener(Event.ENTER_FRAME, f);
					if (type == "add") {
						timer.addEventListener(Event.ENTER_FRAME, f);
					}
				}
			}
		}
		
		public function getOptions():Array {
			var arr:Array = [];
			var i:int;
			
			//Wipe 类使用水平移动的某一形状的动画遮罩来显示或隐藏影片剪辑对象
			for (i = 1; i < 10; i ++) {
				arr.push({
					type : Wipe,
					startPoint : i,
					duration : transition
				});
			}
			
			//Squeeze 类水平或垂直缩放影片剪辑对象
			arr.push({
				type : Squeeze,
				dimension : 1,
				duration : transition
			});
			arr.push({
				type : Squeeze,
				dimension : 0,
				duration : transition
			});
			
			//PixelDissolve 类使用随机出现或消失的棋盘图案矩形来显示影片剪辑对象
			arr.push({
				type : PixelDissolve,
				xSections : 20,
				ySections : 20,
				duration : transition
			});
			arr.push({
				type : PixelDissolve,
				xSections : 10,
				ySections : 10,
				duration : transition
			});
			//Iris 类使用可以缩放的方形或圆形动画遮罩来显示影片剪辑对象
			for (i = 2; i < 10; i ++) {
				arr.push({
					type : Iris,
					startPoint : i,
					shape : Iris.CIRCLE,
					duration : transition
				});
				arr.push({
					type : Iris,
					startPoint : i,
					shape : Iris.SQUARE,
					duration : transition
				});
			}
			
			//Fly 类从某一指定方向滑入影片剪辑对象。 这一效果需要下列参数
			for (i = 1; i < 10; i ++) {
				arr.push({
					type : Fly,
					startPoint : i,
					duration : transition
				});
			}
			//Fade 类淡入或淡出影片剪辑对象
			arr.push({
				type : Fade,
				duration : transition
			});
			//Blinds 类使用逐渐消失或逐渐出现的矩形来显示影片剪辑对象
			arr.push({
				type : Blinds, 
				numStrips : 10,
				dimension : 1,
				duration : transition
			});
			arr.push({
				type : Blinds, 
				numStrips : 10,
				dimension : 0,
				duration : transition
			});
			return arr;
		}
		
	}
}