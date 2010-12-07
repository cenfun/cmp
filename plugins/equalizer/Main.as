package {
	import flash.media.*;
	import flash.net.*;
	import flash.display.*;
	import flash.events.*;
	import flash.system.*;
	import flash.external.*;
	import com.everydayflash.equalizer.*;
	import com.everydayflash.equalizer.color.*;
	
	public class Main extends Sprite{
		//cmp的api接口
		private var cmp_api:Object;
		//cmp分配的侦听通信钥匙
		private var cmp_key:String;
		//
		private var equalizer:Equalizer;
		private var settings:EqualizerSettings;
		
		public function Main() {
			Security.allowDomain("*");
			//插件初始化(插件不能由CMP跨域加载，否则无法初始化，请将插件和CMP放在同一域中)
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
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
			//添加侦听事件，必须传入通信key
			cmp_api.addEventListener(cmp_key, 'video_resize', resizeHandler);
			cmp_api.addEventListener(cmp_key, 'model_state', stateHandler);
			cmp_api.addEventListener(cmp_key, 'mixer_next', nextHandler);
			cmp_api.addEventListener(cmp_key, 'mixer_prev', prevHandler);
			cmp_api.addEventListener(cmp_key, 'mixer_color', colorHandler);
			cmp_api.addEventListener(cmp_key, 'mixer_displace', displaceHandler);
			cmp_api.addEventListener(cmp_key, 'mixer_filter', filterHandler);
			//
			settings = new EqualizerSettings();
			settings.numOfBars = 32;
			settings.hgrid = 3;
			settings.vgrid = true;
			equalizer = new Equalizer();
			addChild(equalizer);
			//
			filterHandler();
			displaceHandler();
			resizeHandler();
			stateHandler();
		}
		private function resizeHandler(e = null) {
			var vw:Number = cmp_api.config['video_width'];
			var vh:Number = cmp_api.config['video_height'];
			if (vw && vh) {
				var tw:Number = vw;
				var th:Number = vh;
				if (th > 350) {
					th = 350;
				}
				if (tw > 384) {
					tw = 384;
				}
				equalizer.x = (vw - tw) * 0.5;
				equalizer.y = (vh - th) * 0.5;
				//
				settings.height = th * 0.7;
				settings.barSize = tw / 32;
				equalizer.update(settings);
			}
		}
		private function colorHandler(e = null):void {
			var color:uint = cmp_api.tools.strings.color(cmp_api.config['mixer_color']) + 0xff000000;
			settings.colorManager = new SolidBarColor(color);
			equalizer.update(settings);
		}
		
		private function nextHandler(e = null):void {
			settings.hgrid ++;
			equalizer.update(settings);
		}
		private function prevHandler(e = null):void {
			if (settings.hgrid > 1) {
				settings.hgrid --;
				equalizer.update(settings);
			}
		}
		private function displaceHandler(e = null):void {
			if (cmp_api.config['mixer_displace']) {
				settings.colorManager = new GradientBarColor();
				equalizer.update(settings);
			} else {
				colorHandler();
			}
		}
		
		private function filterHandler(e = null):void {
			//0,1,2,3
			if (cmp_api.config['mixer_filter']) {
				settings.effect = 1;
			} else {
				settings.effect = 0;
			}
			equalizer.update(settings);
		}

		private function stateHandler(e = null) {
			removeEventListener(Event.ENTER_FRAME, equalizer.render);
			switch (cmp_api.config['state']) {
				case "playing" :
					if (cmp_api.item.type == "sound") {
						visible = true;
						addEventListener(Event.ENTER_FRAME, equalizer.render);
					}
					break;
				default :
					visible = false;
					break;
			}
		}
		
		private function alert(msg):void {
			try {
				ExternalInterface.call("eval", "alert('"+msg+"');");
			} catch (e:Error) {
			}
		}
		
	}
}