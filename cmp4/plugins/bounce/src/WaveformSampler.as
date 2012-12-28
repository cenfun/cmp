package src{
	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;
	public class WaveformSampler extends EventDispatcher {
		protected var stretch:int;
		protected var size:int;
		protected var samplelist:Array;
		protected var spectrum:ByteArray;
		protected var inc:int;

		private var timer:Timer;

		public static const MONO:String = "mono";
		public static const STEREO_LEFT:String = "left";
		public static const STEREO_RIGHT:String = "right";
		public static const SAMPLE:String = "sample";

		protected static var allowInstantiation:Boolean = false;
		protected static var instance:WaveformSampler;

		public function WaveformSampler() {
			if (allowInstantiation) {
				spectrum = new ByteArray();
			}
		}
		public function stop():void {
			timer.stop();
		}
		public function getSamples(type:String = "mono"):Array {
			var n:int = int(size * 0.5);
			var arr:Array;
			var i:int;
			switch (type) {
				case STEREO_LEFT :
					return samplelist.slice(0, n);
				case STEREO_RIGHT :
					return samplelist.slice(n);
				case MONO :
					arr = new Array(n);
					while (i < n) {
						arr[i] = (samplelist[i] + samplelist[(i + n)]) * 0.5;
						i++;
					}
					return arr;
			}
			return null;
		}
		protected function timerHandler(e:Event):void {
			
			if (SoundMixer.areSoundsInaccessible()) {
				//本flash的混合声道不存在任何声音，停止频谱
				stop();
				return;
			} else {
				try {
					SoundMixer.computeSpectrum(spectrum, false, stretch);
				} catch(e:Error) {
				}
			}
			
			if (spectrum) {
				spectrum.position = 0;
				if (!spectrum.bytesAvailable) {
					stop();
					return;
				}
			} else {
				stop();
				return;
			}
			
			var i:int;
			while (i < size) {
				spectrum.position = (inc * i);
				samplelist[i] = spectrum.readFloat();
				i++;
			}
			//dispatchEvent(new Event("sample"));
		}
		public function getSample(m:Number, type:String = "mono"):Number {
			var n:int = int(size * 0.5);
			m = Math.min(1,Math.max(0,m));
			var i:int = Math.round(m * (n - 1));
			switch (type) {
				case STEREO_LEFT :
					return Number(samplelist[i]);
				case STEREO_RIGHT :
					return Number(samplelist[(i + n)]);
				case MONO :
					return Number(samplelist[i] + samplelist[i + n]) * 0.5;
			}
			return NaN;
		}
		public function start(delay:Number, m:int = 8, s:int = 0):void {
			var n:int = 1 << Math.min(Math.max(m,1),8);
			size = int((n * 2));
			inc = int((0x0800 / size));
			stretch = s;
			samplelist = [];
			timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();
		}

		public static function getInstance():WaveformSampler {
			if (instance == null) {
				allowInstantiation = true;
				instance = new (WaveformSampler);
				allowInstantiation = false;
			}
			return instance;
		}

	}
}