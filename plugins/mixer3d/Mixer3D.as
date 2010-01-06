package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.media.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.system.*;
	public class Mixer3D extends Sprite {
		private var bytes: ByteArray;
		private var output: BitmapData;
		private var peaks: BitmapData;
		private var displace: Matrix;
		private var rect: Rectangle;
		private var gradient: Array;
		private var darken: ColorTransform;
		
		private var tx:Number;
		private var ty:Number;
		private var tw:Number;
		private var th:Number;
		
		
		//cmp的api接口
		private var cmp_api:Object;
		//cmp分配的侦听通信钥匙
		private var cmp_key:String;
		//CMP配置信息
		private var cmp_config:Object;

		public function Mixer3D():void {
			Security.allowDomain("*");
			//插件初始化(插件不能由CMP跨域加载，否则无法初始化，请将插件和CMP放在同一域中)
			this.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
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
			//初始化
			init();
			//添加侦听事件，必须传入通信key
			cmp_api.addEventListener(cmp_key, 'video_resize', resizeHandler);
			cmp_api.addEventListener(cmp_key, 'model_state', stateHandler);
			resizeHandler();
		}
		
		private function init():void {
			//初始化
			bytes = new ByteArray();
			displace = new Matrix();
			displace.tx = 2;
			displace.ty = -1;
			darken = new ColorTransform(1, 1, 1, 1, -2, -2, -2, 0);
			rect = new Rectangle(0, 0, 1, 0);
			gradient = createRainbowGradientArray();
		}
		
		private function resizeHandler(e:Event = null) {
			if (cmp_config['video_width'] && cmp_config['video_height']) {
				tw = cmp_config['video_width'];
				th = cmp_config['video_height'];
				//
				tx = (tw - 500) * 0.5;
				if (tx < 0) {
					tx = 0;
				}
				if (th > 300) {
					ty = th * 0.5 + 100;
				} else {
					ty = th - 64;
				}
				while (numChildren) {
					removeChildAt(0);
				}
				output = new BitmapData(tw, th, true, 0);
				peaks = new BitmapData(tw, th, true, 0);
				addChild(new Bitmap(output));
				addChild(new Bitmap(peaks));
				stateHandler();
			}
		}

		private function stateHandler(e:Event = null) {
			removeEventListener(Event.ENTER_FRAME, triggerFrame);
			switch (cmp_config['state']) {
				case "playing" :
					if (cmp_api.item.type == "sound") {
						addEventListener(Event.ENTER_FRAME, triggerFrame);
						visible = true;
					}
					break;
				default :
					visible = false;
					break;
			}
		}
		
		private function triggerFrame(e:Event):void {
			peaks.fillRect(peaks.rect, 0);
			
			bytes = new ByteArray();
			try {
				SoundMixer.computeSpectrum(bytes, true, 0);
			} catch(e:Error) {
			}
			if (!bytes.length) {
				visible = false;
				return;
			}
			visible = true;
			//
			var a:Number;
			var h:Number;
			var s:Number;
			for (var i:int = 0; i < 256; i++) {
				a = bytes.readFloat();
				if (i == 0) {
					s = a;
				} else {
					s += (a - s) * 0.125;
				}
				h = 2 + s * 0xf0;
				rect.x = tx + i;
				rect.y = ty + (i >> 2) - h;
				rect.height = h;
				peaks.setPixel32(rect.x, rect.y, 0xffffffff);
				output.fillRect(rect, 0xff000000 | gradient[i]);
			}
			output.draw(output, displace, darken, null, null, true);

		}
		private function createRainbowGradientArray():Array {
			var gradient: Array = new Array();
			var shape: Shape = new Shape();
			var bmp: BitmapData = new BitmapData(256, 1, false, 0);
			var colors: Array = [0, 0xff0000, 0xffff00, 0x00ff00, 0x00ffff];
			var alphas: Array = [100, 100, 100, 100, 100];
			var ratios: Array = [0, 16, 128, 192, 255];
			var matrix: Matrix = new Matrix();
			matrix.createGradientBox(256, 1, 0, 0, 0);
			shape.graphics.beginGradientFill("linear", colors, alphas, ratios, matrix);
			shape.graphics.drawRect(0, 0, 256, 1);
			shape.graphics.endFill();
			bmp.draw(shape);
			for (var i: int = 0; i < 256; i++) {
				gradient[i] = bmp.getPixel(i, 0);
			}
			return gradient;
		}
	}
}