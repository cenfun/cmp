package com.anttikupila.revolt.presets {
	import com.anttikupila.revolt.presets.Preset;
	import com.anttikupila.revolt.drawers.*;
	import com.anttikupila.revolt.effects.*;
	import com.anttikupila.revolt.scalers.*;
	
	public class LineNoFourier extends Preset {
		function LineNoFourier(clr:String=undefined) {
			super();
			fourier = false;
			drawers = new Array(new SimpleLine(clr));
			effects = new Array(new Blur(),new Tint(0x000000,0.25));
			scalers = new Array();
		}
		
		public function toString():String {
			return "Line with fourier transformation";
		}
	}
}