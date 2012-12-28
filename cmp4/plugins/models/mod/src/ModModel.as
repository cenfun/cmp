package {
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	
	import de.popforge.audio.output.*;
	import de.popforge.audio.output.*;
	import de.popforge.audio.processor.bitboy.*;
	import de.popforge.audio.processor.bitboy.formats.*;
	import de.popforge.format.wav.*;
	
	public final class ModModel extends Object {
		public var url:String;
		public var position:Number = 0;
		public var loaded:Boolean;
		//下载字节和总字节
		public var bl:int;
		public var bt:int;
		//时间控制者
		public var timer:Sprite = new Sprite();

		//====================================================================================
		public var CMP:Object;
		public var apikey:Object;
		public var api:Object;
		
		public var loader:URLLoader;
		
		public var BUFFER_SIZE:int = 4096;
		
		private var bitboy:BitBoy;
		private var format:FormatBase;

		private var sound:Sound;
		private var buffer:Array;
		private var isRunning:Boolean;
		
		private var startTime: uint;
		
		public function ModModel(_apikey:Object):void {
			apikey = _apikey;
			api = apikey.api;
			//取得cmp构造函数
			CMP = api.cmp.constructor;
			
			bitboy = new BitBoy();

			buffer = new Array();

			for (var i: int = 0; i < BUFFER_SIZE; ++i) {
				buffer[i] = new Sample();
			}
		}
		
		private function onSampleData( e: SampleDataEvent ): void {
			if( isRunning ) {
				bitboy.processAudio( buffer );
				if( bitboy.isIdle() ) {
					onModComplete();
				}
			}
			
			for(var i:int = 0; i < BUFFER_SIZE; i++) {
				var sample:Sample = buffer[i];
				
				e.data.writeFloat(sample.left);
				e.data.writeFloat(sample.right);
				
				sample.left = 0.0;
				sample.right = 0.0;
			}
		}
		
		//==================
		public function load():void {
			api.sendState("connecting");
			loaded = false;
			url = api.item.url;
			
			startTime = int.MAX_VALUE;
			isRunning = false;
			
			loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
			loader.addEventListener(Event.COMPLETE, onLoaded);
			var req:URLRequest = new URLRequest(url);
			try {
				loader.load(req);
			} catch (e:Error) {
				onError();
			}
			
		}
		public function onError(e:Event = null):void {
			api.sendEvent("model_error", "加载mod文件失败");
		}
		
		private function onProgress(e:ProgressEvent):void {
			if(e.bytesTotal > 0 && e.bytesLoaded < e.bytesTotal) {
				var per:Number = e.bytesLoaded / e.bytesTotal;
				api.sendEvent("model_loading", per);
				
				var bper:Number = Math.floor(per * 100);
				//trace(bper);
				if (bper < 100) {
					api.config.buffer_percent = bper;
					api.sendState("buffering");
				}
				
				
				if (!api.item.data) {
					api.item.data = true;
				}
			}
		}
		//信息加载完成
		public function onLoaded(e:Event):void {
			api.sendEvent("model_loaded");
			var ba:ByteArray = e.target.data;
			if (!ba) {
				onError();
				return;
			}
			
			format = FormatFactory.createFormat(ba);
			
			bitboy.setFormat(format);
			
			api.item.duration = bitboy.getLengthSeconds();
			
			
			bitboy.parameterPause.setValue( false );
			
			startTime = getTimer() * 0.001;
			
			loader = null;
			
			isRunning = true;
			
			
			//sound
			sound = new Sound();
			sound.addEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
			sound.play();
			
			api.sendEvent("model_start");
			
			play();
			
			api.showMixer(true);
			
		}
		
		public function play():void {
			bitboy.parameterPause.setValue( false );
			volume();
			interval("add", [timeHandler]);
			api.sendState("playing");
		}
		public function pause():void {
			interval("del", [timeHandler]);
			bitboy.parameterPause.setValue( true );
			api.sendState("paused");
		}
		public function stop():void {
			interval("del", [timeHandler]);
			
			if (sound) {
				sound.removeEventListener( SampleDataEvent.SAMPLE_DATA, onSampleData );
				sound = null;
			}
			
			if (format) {
				bitboy.parameterPause.setValue( true );
				bitboy.reset();
			}
			
			//停止加载列表
			if (loader) {
				loader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				loader.removeEventListener(ProgressEvent.PROGRESS, onProgress);
				loader.removeEventListener(Event.COMPLETE, onLoaded);
				try {
					loader.close();
				} catch (e:Error) {
				}
				loader = null;
			}
			
		}
		
		public function volume():void {
			
			bitboy.parameterGain.setValueNormalized( api.config.volume );
			
		}
		public function seek(val:Number):void {
			
			bitboy.setPosition(val);
			
			//如果暂停则恢复播放
			if (api.config.state == "paused") {
				play();
			}
			
		}
		
		//时间控制
		public function timeHandler(e:Event):void {
			
			position = bitboy.getPosition();
			
			//发送时间变更事件
			if (position != api.item.position && position <= api.item.duration && api.config.state == "playing") {
				api.item.position = position;
				api.sendEvent("model_time");
			}
			
		}
		
		//播放完成
		public function onModComplete():void {
			
			interval("del", [timeHandler]);
			
			startTime = int.MAX_VALUE;
			bitboy.parameterPause.setValue( true );
			
			finish();
		}
		
		//完成
		public function finish():void {
			//先停止当前模块
			stop();
			api.sendState("completed");
		}
		//取得媒体资料
		public function metaHandler(info:Object):void {
			//api.item.data = true;
			//api.sendEvent("model_meta", info);
		}
		
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

	}
}