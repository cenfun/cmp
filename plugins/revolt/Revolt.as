package {
	import com.anttikupila.revolt.presets.*;
	import flash.media.*;
	import flash.display.*;
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	public final class Revolt extends Sprite {

		public var config:Object = {gain:1, simple:false, sound:false, timeout:10};
		private var presets:Array;
		private var randomizer:Randomizer;
		private var clip:Sprite;
		private var bitmap:BitmapData;
		private var array:ByteArray;
		private var timeout:Number;
		private var current:Preset;
		//cmp的api接口
		private var cmp_api:Object;
		//cmp分配的侦听通信钥匙
		private var cmp_key:String;
		//CMP配置信息
		private var cmp_config:Object;

		public function Revolt() {
			Security.allowDomain("*");
			presets = new Array(new LineFourier(), new Explosion(),new LineSmooth(),new LineWorm(),new Tunnel());
			randomizer = new Randomizer(presets.length);
			//插件初始化(插件不能由CMP跨域加载，否则无法初始化，请将插件和CMP放在同一域中)
			loaderInfo.sharedEvents.addEventListener('api', apiHandler);
		}

		private function apiHandler(e):void {
			//取得cmp的api对象和侦听key，包含2个属性{api,key}
			var apikey:Object = e.data;
			//如果没有取到则直接返回
			if (! apikey) {
				return;
			}
			cmp_api = apikey.api;
			cmp_key = apikey.key;
			//取得cmp配置信息
			cmp_config = cmp_api.config;
			//添加侦听事件，必须传入通信key
			cmp_api.addEventListener(cmp_key, 'video_resize', resizeHandler);
			cmp_api.addEventListener(cmp_key, 'model_state', stateHandler);
			cmp_api.addEventListener(cmp_key, 'mixer_next', clickHandler);
			cmp_api.addEventListener(cmp_key, 'mixer_prev', clickHandler);
			//
			bitmap = new BitmapData(320, 240, false, 0x000000);
			array = new ByteArray();
			clip = new Sprite();
			addChild(clip);
			clip.visible = false;
			var pic:Bitmap = new Bitmap(bitmap);
			pic.smoothing = true;
			clip.addChild(pic);
			
			resizeHandler();
			stateHandler();
			
			if (config['simple']) {
				current = new LineNoFourier(cmp_config['mixer_color']);
			} else {
				next();
			}
		}

		private function clickHandler(e:Event):void {
			if (config['simple']) {
				cmp_api.sendEvent("view_play");
			} else {
				next();
			}
		}

		private function compute(ev:Event):void {
			array = new ByteArray();
			try {
				SoundMixer.computeSpectrum(array, current.fourier, 0);
			} catch(e:Error) {
			}
			if (!array.length) {
				clip.visible = false;
				return;
			}
			clip.visible = true;
			var soundArray:Array = new Array();
			for (var i:int = 0; i < 512; i++) {
				soundArray.push(array.readFloat() * config['gain']);
			}
			current.applyGfx(bitmap, soundArray);
		}

		private function next(e:Event = null):void {
			clearTimeout(timeout);
			if (!config['simple']) {
				current = presets[randomizer.pick()];
				timeout = setTimeout(next, config['timeout'] * 1000);
			}
		}


		private function resizeHandler(e:Event = null) {
			if (cmp_config['video_width'] && cmp_config['video_height']) {
				clip.width = cmp_config['video_width'];
				clip.height = cmp_config['video_height'];
			}
		}

		private function stateHandler(e:Event = null) {
			removeEventListener(Event.ENTER_FRAME, compute);
			clearTimeout(timeout);
			switch (cmp_config['state']) {
				case "playing" :
					if (cmp_api.item.type == "sound") {
						addEventListener(Event.ENTER_FRAME, compute);
						clip.visible = true;
						if (!config['simple']) {
							timeout = setTimeout(next, config['timeout'] * 1000);
						}
					}
					break;
				default :
					clip.visible = false;
					break;
			}
		}

	}
}