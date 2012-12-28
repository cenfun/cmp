package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.system.*;
	import flash.utils.*;
	public final class BufferNext extends Sprite {
		public var api:Object;
		//缓冲加载器
		private var buffer:Loader;
		private var buffer_id:int;
		private var tree:Object;
		
		public function BufferNext():void {
			Security.allowDomain("*");
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
			root.loaderInfo.sharedEvents.addEventListener('api_remove',removeHandler);
		}
		override public function set width(v:Number):void {
		}
		override public function set height(v:Number):void {
		}
		public function removeHandler(e):void {
			bufferClose();
		}
		private function apiHandler(e):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			api = apikey.api;
			
			//cmp树列表引用
			tree = api.win_list.list.tree;
			
			//当前模块加载完成后调用，用于缓冲下一个
			api.addEventListener(apikey.key, "model_loaded", bufferHandler);
			
			//模块开始加载时先停止之前缓冲
			api.addEventListener(apikey.key, "model_load", stopHandler);
			//停止事件，同样停止缓冲
			api.addEventListener(apikey.key, "view_stop", stopHandler);
			
		}
		
		//停止
		private function stopHandler(e:Event):void {
			bufferClose();
		}
		
		//缓冲系统
		private function bufferHandler(e:Event):void {
			//关闭当前缓冲
			bufferClose();
			//判断下一个===========================
			//顺序播放模式才进行
			if (api.config.play_mode != "normal") {
				return;
			}
			
			//列表项长度必须大于2个才有缓冲
			if (!tree || tree.length < 2) {
				return;
			}
			
			//取得下一个的id位置
			buffer_id = api.config.play_id;
			if (buffer_id >= tree.length) {
				buffer_id = 0;
			}
			//取得下一个的src路径
			var item:Object = tree.getItemAt(buffer_id);
			if (!item) {
				return;
			}
			var url:String = item.src;
			//没有src的不缓存
			if (!url) {
				return;
			}
			//不是http的也不缓存
			if (url.indexOf("http://") != 0) {
				return;
			}
			
			//api.tools.output(url);
			
			buffer = new Loader();
			buffer.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, bufferError, false, 0, true);
			buffer.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, bufferLoading, false, 0, true);
			
			try {
				buffer.load(new URLRequest(url));
			} catch (e:Error) {
			}
			
		}
		private function bufferClose():void {
			if (buffer) {
				
				buffer.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, bufferError);
				buffer.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, bufferLoading);
				
				try {
					buffer.close();
				} catch (e:Error) {
				}
				try {
					buffer.unloadAndStop();
				} catch (e:Error) {
				}
				buffer = null;
			}
		}
		private function bufferError(e:IOErrorEvent):void {
			//trace("buffer error")
			//不用管错误，因为格式本来就不对
		}
		private function bufferLoading(e:ProgressEvent):void {
			
			var bl:int = e.bytesLoaded
			var tl:int = e.bytesTotal;
			//没有总长度就停止缓冲，可能是直播
			if (bl > 0 && !tl) {
				bufferClose();
				return;
			}
			
			//总大小超过100M也停止缓冲，减少不必要的下载
			if (tl > 100 * 1000 * 1000) {
				bufferClose();
				return;
			}
			
		}
		

	}
}