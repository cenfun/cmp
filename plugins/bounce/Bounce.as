package {
	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;
	import flash.media.*;
	import flash.utils.*;
	import flash.net.*;
	import src.*;
	public class Bounce extends Sprite {
		private var timer:Timer;
		private var freqSampler:FrequencySampler;
		private var screen:Screen;
		private var ballBin:Sprite;
		private var waveSampler:WaveformSampler;
		private var rect:Rectangle;

		public function Bounce() {
			freqSampler = FrequencySampler.getInstance();
			waveSampler = WaveformSampler.getInstance();
			waveSampler.start(30, 7);
			rect = new Rectangle(10,10,600,200);
			screen = new Screen(rect);
			ballBin = new Sprite();
			this.addChild(screen);
			this.addChild(ballBin);
			
			var sound:Sound = new Sound();
			sound.addEventListener(IOErrorEvent.IO_ERROR, catchError);
			sound.addEventListener(SecurityErrorEvent.SECURITY_ERROR, catchError);
			sound.load(new URLRequest("music.mp3"));
			var channel:SoundChannel = sound.play();
			
			timer = new Timer(1000, 200);
			timer.addEventListener(TimerEvent.TIMER, spawnBall);
			timer.start();
		}
		private function catchError(e:ErrorEvent):void {
		}
		private function spawnBall(e:Event):void {
			var b:Ball;
			if (timer.currentCount > 15) {
				timer.stop();
				return;
			}
			trace(timer.currentCount);
			b = new Ball(screen);
			ballBin.addChild(b);
			b.x = rect.left + (Math.random() * rect.width);
			b.y = 50;
		}

	}
}