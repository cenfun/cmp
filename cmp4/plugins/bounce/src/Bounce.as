package src {
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;
	import flash.media.*;
	import flash.net.*;
	import flash.filters.*;
	import src.*;
	public class Bounce extends Sprite {
		
		private var freqSampler:FrequencySampler;
		private var waveSampler:WaveformSampler;
		
		private var screen:Screen;
		private var effect:Sprite;
		private var balls:Sprite;
		private var rect:Rectangle;
		
		private var dp:Boolean = false;
		private var ft:Boolean = false;
		private var cl:Boolean = false;
		private var rt:Rectangle;
		private var bd:BitmapData;
		private var br:BlurFilter = new BlurFilter(8, 8, 3);
		private var pt:Point = new Point(0, 0);
		
		private var vw:Number = 320;
		private var vh:Number = 240;
		
		private var api:Object;
		
		//最多8个球
		private var max_ball:int = 8;

		public function Bounce() {
			freqSampler = FrequencySampler.getInstance();
			waveSampler = WaveformSampler.getInstance();
			waveSampler.start(30, 7);
			screen = new Screen();
			effect = new Sprite();
			balls = new Sprite();
			addChild(screen);
			addChild(effect);
			addChild(balls);
			//api侦听
			root.loaderInfo.sharedEvents.addEventListener('api', apiHandler);
		}
		
		private function apiHandler(e:Event):void {
			var apikey:Object = e.data;
			if (! apikey) {
				return;
			}
			//取得api的引用
			api = apikey.api;
			//添加侦听事件
			api.addEventListener(apikey.key, 'video_resize', resizeHandler);
			api.addEventListener(apikey.key, 'model_state', stateHandler);
			api.addEventListener(apikey.key, 'model_start', startHandler);
			api.addEventListener(apikey.key, 'mixer_next', nextHandler);
			api.addEventListener(apikey.key, 'mixer_prev', prevHandler);
			api.addEventListener(apikey.key, 'mixer_color', colorHandler);
			api.addEventListener(apikey.key, 'mixer_displace', displaceHandler);
			api.addEventListener(apikey.key, 'mixer_filter', filterHandler);
			
			colorHandler();
			filterHandler();
			resizeHandler();
			startHandler();
		}
		
		private function nextHandler(e:Event):void {
			addBall();
		}
		private function prevHandler(e:Event):void {
			removeBall();
		}
		
		private function colorHandler(e:Event = null):void {
			screen.color = api.tools.strings.color(api.config['mixer_color']);
			//api.tools.output(mc);
		}
		
		private function displaceHandler(e:Event):void {
			//dp = api.config["mixer_displace"];
		}
		
		private function filterHandler(e:Event = null):void {
			ft = api.config['mixer_filter'];
		}
		
		//====================================================================
		private function resizeHandler(e:Event = null) {
			vw = api.config['video_width'];
			vh = api.config['video_height'];
			if (vw && vh) {
				rt = new Rectangle(0,0,vw,vh);
				rect = new Rectangle(0,0,vw,vh - 50);
				screen.rect = rect;
				screen.visible = true;
				//滤镜
				bd = new BitmapData(vw, vh, true, 0x00000000);
				//清除mF
				while (effect.numChildren) {
					effect.removeChildAt(0);
				}
				//添加新的
				effect.addChild(new Bitmap(bd));
			} else {
				screen.visible = false;
			}
		}

		private function stateHandler(e:Event) {
			switch (api.config['state']) {
				case "stopped" :
					clear();
					break;
				default :
			}
		}
		
		private function startHandler(e:Event = null) {
			clear();
			if (api.item) {
				if (api.item.type == "sound") {
					start();
				}
			}
		}
		
		private function start():void {
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
			addBalls();
			visible = true;
		}
		
		public function update(e:Event):void {
			screen.update();
			if (rt.width > 600 || rt.height > 400 || !ft) {
				//过大时，自动关闭滤镜
				if (!cl) {
					cl = true;
					bd.fillRect(bd.rect, 0);
				}
				return;
			}
			cl = false;
			bd.draw(balls);
			bd.applyFilter(bd, rt, pt, br);
		}
		
		private function clear():void {
			removeEventListener(Event.ENTER_FRAME, update);
			removeBalls();
			visible = false;
		}
		
		private function addBalls():void {
			var num:uint = max_ball;
			while (num > 0) {
				addBall();
				num --;
			}
		}
		private function addBall():void {
			var b:Ball = new Ball(screen);
			balls.addChild(b);
			b.x = rect.left + (Math.random() * rect.width);
			b.y = rect.height * 0.3;
		}
		private function removeBalls():void {
			while (balls.numChildren) {
				removeBall();
			}
		}
		private function removeBall():void {
			if (balls.numChildren) {
				balls.removeChildAt(0);
			}
		}
		
	}
}