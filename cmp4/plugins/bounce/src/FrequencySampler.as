package src{
	import flash.events.*;
	import flash.media.*;

	public class FrequencySampler extends WaveformSampler {

		private static var instance:FrequencySampler;

		override protected function timerHandler(e:Event):void {
			if (SoundMixer.areSoundsInaccessible()) {
				stop();
				return;
			}
			SoundMixer.computeSpectrum(spectrum, true, stretch);
			var i:int;
			while (i < size) {
				spectrum.position = (inc * i);
				samplelist[i] = spectrum.readFloat();
				i ++;
			}
			//dispatchEvent(new Event("sample"));
		}

		public static function getInstance():FrequencySampler {
			if (instance == null) {
				WaveformSampler.allowInstantiation = true;
				instance = new FrequencySampler();
				WaveformSampler.allowInstantiation = false;
			}
			return instance;
		}

	}
}