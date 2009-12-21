/**
 * Copyright (c) 2008 Bartek Drozdz (http://www.everydayflash.com)
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

 /**
  * EQUALIZER VERSION 1.0 (March 27th 2008)
  * 
  * The base class for the Equalizer. Typical use cases are:
  * 
  * var e:Equalizer = new Equalizer();
  * addChild(e);
  * addEventListener(Event.ENTER_FRAME, equalizer.render);
  * 
  * or with custom settings:
  * 
  * var s:EqualizerSettings = new EqualizerSettings();
  * s.numOfBars = 16;
  * s.vgrid = true;
  * s.hgrid = 2;
  * // ...see EqualizerSettings for other options 
  * var e:Equalizer = new Equalizer(s);
  * addChild(e);
  * addEventListener(Event.ENTER_FRAME, equalizer.render);
  * 
  * The update method can be used to dynamically chnage the settings
  * of the Equalizer. It was important for the demo I created, but
  * isn't probalby that useful in everyday life...
  * 
  * NOTE. To run the Equalizer you need the com.gskinner.geom.ColorMatrix class by Grant Skinner.
  * I included it in the source, but it is also available for download here: 
  * http://www.gskinner.com/blog/archives/2007/12/colormatrix_upd.html
  * 
  * Have fun!
  * Bartek Drozdz
  */
 package com.everydayflash.equalizer {
	 
	import com.everydayflash.equalizer.util.SpectrumReader;
	import flash.display.*;
	import flash.display.BitmapData;
	import flash.events.Event;
	
	/**
	  * @author Bartek Drozdz (http://www.everydayflash.com)
	  * @version 1.0
	  */
	public class Equalizer extends Sprite {
		
		public var canvas:BitmapData;
		private var canvasHolder:Bitmap;
		
		private var settings:EqualizerSettings;
		private var reader:SpectrumReader;
		private var effects:EqualizerEffects;

		public function Equalizer(settings:EqualizerSettings = null) {
			if (settings == null) settings = new EqualizerSettings();
			effects = new EqualizerEffects(this);
			update(settings);
		}
		
		public function update(s:EqualizerSettings):void {
			settings = s;
			if (canvas != null && contains(canvasHolder)) {
				removeChild(canvasHolder);
				canvas.dispose();
			}

			reader = new SpectrumReader(settings.numOfBars);
			
			settings.colorManager.setSettings(settings);

			canvas = new BitmapData(settings.getWidth(), settings.height, true, 0x00000000);
			canvasHolder = new Bitmap(canvas);
			addChild(canvasHolder);
				
			effects.update(settings);
		}
		
		public function getSettings():EqualizerSettings {
			return settings;
		}
		
		/**
		 * The dirty job goes here.
		 * 
		 * @param	e Event, typically Event.ON_ENTER_FRAME
		 */
		public function render(e:Event):void {
			canvas.lock();
			var spectrum:Array = reader.getSpectrum();
			
			var m:int = reader.getSize() / 2;
			var bp:int = settings.barSize;
			var gs:int = (settings.vgrid && settings.barSize > 1) ? 1 : 0;
			var i:int, j:int, b:int;

			for(i = 0; i < reader.getSize(); i++) {
				var value:Number = Math.min(settings.height, Math.round(spectrum[i] * settings.height));
				
				// Erasing the previous bars
				var nbf:Number = 0;
				
				
				for (j = 0; j < settings.height; j++) {
					if (canvas.getPixel32((i * bp), j) != 0x00000000) {
						for (b = 0; b < bp-gs; b++)  
							canvas.setPixel32((i * bp) + b, j, 0x00000000);
						if (settings.hgrid == 0) nbf++;
						else if (settings.hgrid != 0 && j % settings.hgrid == 0) nbf++;
					}
					
					if (nbf > settings.height / (32*(settings.hgrid+1))) break;
					
				}
				
				// Rendering new bars
				for (j = 0; j < value; j++) {
					if (settings.hgrid != 0 && j % settings.hgrid == 1) continue;
					if (settings.hgrid != 0 && value / settings.hgrid < 1) break;
					
					for (b = 0; b < bp-gs; b++) 
						canvas.setPixel32((i * bp) + b, settings.height - j, settings.colorManager.getColor(i, j));
				}
				
				
			}
			
			canvas.unlock();
			settings.colorManager.onRendered();
			effects.onRendered();
		}
	}
	
}





















