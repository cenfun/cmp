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

 package com.everydayflash.equalizer.color {
	
	import com.everydayflash.equalizer.EqualizerSettings;
	
	/**
	  * @author Bartek Drozdz (http://www.everydayflash.com)
	  * @version 1.0
	  */
	public class GradientBarColor implements BarColor {
		
		private var tc:Array;
		private var bc:Array;
		private var settings:EqualizerSettings;
		
		public function GradientBarColor(topColorRGB:uint=0x00ff00, bottomColorRGB:uint=0xff0000) {
			tc = [(topColorRGB >> 16) & 0xff, (topColorRGB >> 8) & 0xff, topColorRGB & 0xff];
			bc = [(bottomColorRGB >> 16) & 0xff, (bottomColorRGB >> 8) & 0xff, bottomColorRGB & 0xff];
		}
		
		public function setSettings(settings:EqualizerSettings):void {
			this.settings = settings;
		}
		
		public function getColor(x:int, y:int):uint {
			var p:Number = (y / settings.height);
			var alpha:int = 255 << 24;
			var red:int =  (tc[0] + p*(bc[0] - tc[0])) << 16;
			var green:int =  (tc[1] + p*(bc[1] - tc[1])) << 8;
			var blue:int = tc[2] + p*(bc[2] - tc[2]);
			
			return alpha + red + green + blue;
		}
		
		public function onRendered():void {
			// Gradient color does not need to be notified after each render
		}
	}
}















