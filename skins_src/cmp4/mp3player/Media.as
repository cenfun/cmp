package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.ui.*;
	import flash.utils.*;
	
	public class Media extends Sprite {

		//cmp的api接口
		private var api:Object;

		private var loader:Loader;
		
		//修正加载皮肤时找不到bitmapData属性报错的情况
		public var bitmapData:BitmapData;
		
		public function Media() {
			//侦听api的发送
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove', apiRemoveHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			api = apikey.api;
			//添加侦听事件，必须传入通信key
			//改变大小时调用
			api.addEventListener(apikey.key, 'video_resize', resizeHandler);
			//状态改变时调用
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'model_start', startHandler);
			
			loadImage();
			
			if (api.config.state != "playing") {
				api.win_list.media.video.vi.ip.visible = true;
			}
			//初始位置尺寸
			resizeHandler();
			//初始化播放状态
			stateHandler();
		}
		
		//皮肤删除时调度
		private function apiRemoveHandler(e:Event = null):void {
			
			api.win_list.media.video.vi.ip.visible = false;
			
		}
		
		
		private function loadImage():void {

			if (!api.config.image) {
				return;
			}
			
			//api.tools.output(api.config.image);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			var request:URLRequest = new URLRequest(api.config.image);
            loader.load(request);
          	img.addChild(loader);
		}
		private function completeHandler(event:Event):void {
			resizeHandler();
        }
		private function ioErrorHandler(event:IOErrorEvent):void {
        }
		
		//video_scalemode: 缩放模式 默认为1
		//1在指定区域中可见，且不会发生扭曲，同时保持应用程序的原始高宽比
		//2在指定区域中可见，但不尝试保持原始高宽比。可能会发生扭曲，应用程序可能会拉伸或压缩显示
		//3指定整个应用程序填满指定区域，不会发生扭曲，但有可能会进行一些裁切，同时保持应用程序的原始高宽比
		//0不进行缩放，即使在更改播放器窗口大小时，它仍然保持不变


		//尺寸改变时调用
		private function resizeHandler(e:Event = null):void {
			//获取cmp的宽高
			var cw:Number = api.config.video_width;
			var ch:Number = api.config.video_height;
			//
			bgd.width = bg.width = cw;
			bgd.height = bg.height = ch;
			
			api.tools.zoom.fit(img, cw, ch, api.config.video_scalemode);
			
			x = api.win_list.media.video.x;
			y = api.win_list.media.video.y;
			
			
			//api.tools.output(cw + "|" + ch);
		}

		//播放状态改变时调用
		private function stateHandler(e:Event = null):void {
			
			//停止后显示图片
			if (api.config.state == "stopped") {
				img.visible = true;
				api.win_list.media.video.vi.ip.visible = true;
			}
			
			//播放视频时隐藏默认背景
			if (api.item && api.item.type == "video" && api.config.state != "stopped") {
				bgd.visible = false;
			} else {
				bgd.visible = true;
			}
			
		}
		
		private function startHandler(e:Event = null):void {
			img.visible = false;
		}

		

	}

}